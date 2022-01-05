// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show jsonDecode;
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:yaml/yaml.dart';

import './git.dart';
import './globals.dart';
import './stdio.dart';
import './version.dart';

/// Allowed git remote names.
enum RemoteName {
  upstream,
  mirror,
}

class Remote {
  const Remote({
    required RemoteName name,
    required this.url,
  })  : _name = name,
        assert(url != null),
        assert(url != '');

  final RemoteName _name;

  /// The name of the remote.
  String get name {
    switch (_name) {
      case RemoteName.upstream:
        return 'upstream';
      case RemoteName.mirror:
        return 'mirror';
    }
  }

  /// The URL of the remote.
  final String url;
}

/// A source code repository.
abstract class Repository {
  Repository({
    required this.name,
    required this.upstreamRemote,
    required this.processManager,
    required this.stdio,
    required this.platform,
    required this.fileSystem,
    required this.parentDirectory,
    this.initialRef,
    this.localUpstream = false,
    this.previousCheckoutLocation,
    this.mirrorRemote,
  })  : git = Git(processManager),
        assert(localUpstream != null),
        assert(upstreamRemote.url.isNotEmpty);

  final String name;
  final Remote upstreamRemote;

  /// Remote for user's mirror.
  ///
  /// This value can be null, in which case attempting to access it will lead to
  /// a [ConductorException].
  final Remote? mirrorRemote;

  /// The initial ref (branch or commit name) to check out.
  final String? initialRef;
  final Git git;
  final ProcessManager processManager;
  final Stdio stdio;
  final Platform platform;
  final FileSystem fileSystem;
  final Directory parentDirectory;

  /// If the repository will be used as an upstream for a test repo.
  final bool localUpstream;

  Directory? _checkoutDirectory;
  String? previousCheckoutLocation;

  /// Directory for the repository checkout.
  ///
  /// Since cloning a repository takes a long time, we do not ensure it is
  /// cloned on the filesystem until this getter is accessed.
  Future<Directory> get checkoutDirectory async {
    if (_checkoutDirectory != null) {
      return _checkoutDirectory!;
    }
    if (previousCheckoutLocation != null) {
      _checkoutDirectory = fileSystem.directory(previousCheckoutLocation);
      if (!_checkoutDirectory!.existsSync()) {
        throw ConductorException(
            'Provided previousCheckoutLocation $previousCheckoutLocation does not exist on disk!');
      }
      if (initialRef != null) {
        assert(initialRef != '');
        await git.run(
          <String>['fetch', upstreamRemote.name],
          'Fetch ${upstreamRemote.name} to ensure we have latest refs',
          workingDirectory: _checkoutDirectory!.path,
        );
        // Note: if [initialRef] is a remote ref the checkout will be left in a
        // detached HEAD state.
        await git.run(
          <String>['checkout', initialRef!],
          'Checking out initialRef $initialRef',
          workingDirectory: _checkoutDirectory!.path,
        );
      }
      return _checkoutDirectory!;
    }

    _checkoutDirectory = parentDirectory.childDirectory(name);
    await lazilyInitialize(_checkoutDirectory!);
    return _checkoutDirectory!;
  }

  /// Ensure the repository is cloned to disk and initialized with proper state.
  Future<void> lazilyInitialize(Directory checkoutDirectory) async {
    if (checkoutDirectory.existsSync()) {
      stdio.printTrace('Deleting $name from ${checkoutDirectory.path}...');
      checkoutDirectory.deleteSync(recursive: true);
    }

    stdio.printTrace(
      'Cloning $name from ${upstreamRemote.url} to ${checkoutDirectory.path}...',
    );
    await git.run(
      <String>[
        'clone',
        '--origin',
        upstreamRemote.name,
        '--',
        upstreamRemote.url,
        checkoutDirectory.path
      ],
      'Cloning $name repo',
      workingDirectory: parentDirectory.path,
    );
    if (mirrorRemote != null) {
      await git.run(
        <String>['remote', 'add', mirrorRemote!.name, mirrorRemote!.url],
        'Adding remote ${mirrorRemote!.url} as ${mirrorRemote!.name}',
        workingDirectory: checkoutDirectory.path,
      );
      await git.run(
        <String>['fetch', mirrorRemote!.name],
        'Fetching git remote ${mirrorRemote!.name}',
        workingDirectory: checkoutDirectory.path,
      );
    }
    if (localUpstream) {
      // These branches must exist locally for the repo that depends on it
      // to fetch and push to.
      for (final String channel in kReleaseChannels) {
        await git.run(
          <String>['checkout', channel, '--'],
          'check out branch $channel locally',
          workingDirectory: checkoutDirectory.path,
        );
      }
    }

    if (initialRef != null) {
      await git.run(
        <String>['checkout', '${upstreamRemote.name}/$initialRef'],
        'Checking out initialRef $initialRef',
        workingDirectory: checkoutDirectory.path,
      );
    }
    final String revision = await reverseParse('HEAD');
    stdio.printTrace(
      'Repository $name is checked out at revision "$revision".',
    );
  }

  /// The URL of the remote named [remoteName].
  Future<String> remoteUrl(String remoteName) async {
    assert(remoteName != null);
    return git.getOutput(
      <String>['remote', 'get-url', remoteName],
      'verify the URL of the $remoteName remote',
      workingDirectory: (await checkoutDirectory).path,
    );
  }

  /// Verify the repository's git checkout is clean.
  Future<bool> gitCheckoutClean() async {
    final String output = await git.getOutput(
      <String>['status', '--porcelain'],
      'check that the git checkout is clean',
      workingDirectory: (await checkoutDirectory).path,
    );
    return output == '';
  }

  /// Return the revision for the branch point between two refs.
  Future<String> branchPoint(String firstRef, String secondRef) async {
    return (await git.getOutput(
      <String>['merge-base', firstRef, secondRef],
      'determine the merge base between $firstRef and $secondRef',
      workingDirectory: (await checkoutDirectory).path,
    )).trim();
  }

  /// Fetch all branches and associated commits and tags from [remoteName].
  Future<void> fetch(String remoteName) async {
    await git.run(
      <String>['fetch', remoteName, '--tags'],
      'fetch $remoteName --tags',
      workingDirectory: (await checkoutDirectory).path,
    );
  }

  /// Create (and checkout) a new branch based on the current HEAD.
  ///
  /// Runs `git checkout -b $branchName`.
  Future<void> newBranch(String branchName) async {
    await git.run(
      <String>['checkout', '-b', branchName],
      'create & checkout new branch $branchName',
      workingDirectory: (await checkoutDirectory).path,
    );
  }

  /// Check out the given ref.
  Future<void> checkout(String ref) async {
    await git.run(
      <String>['checkout', ref],
      'checkout ref',
      workingDirectory: (await checkoutDirectory).path,
    );
  }

  /// Obtain the version tag at the tip of a release branch.
  Future<String> getFullTag(
    String remoteName,
    String branchName, {
    bool exact = true,
  }) async {
    // includes both stable (e.g. 1.2.3) and dev tags (e.g. 1.2.3-4.5.pre)
    const String glob = '*.*.*';
    // describe the latest dev release
    final String ref = 'refs/remotes/$remoteName/$branchName';
    return git.getOutput(
      <String>[
        'describe',
        '--match',
        glob,
        if (exact) '--exact-match',
        '--tags',
        ref,
      ],
      'obtain last released version number',
      workingDirectory: (await checkoutDirectory).path,
    );
  }

  /// List commits in reverse chronological order.
  Future<List<String>> revList(List<String> args) async {
    return (await git.getOutput(<String>['rev-list', ...args],
            'rev-list with args ${args.join(' ')}',
            workingDirectory: (await checkoutDirectory).path))
        .trim()
        .split('\n');
  }

  /// Look up the commit for [ref].
  Future<String> reverseParse(String ref) async {
    final String revisionHash = await git.getOutput(
      <String>['rev-parse', ref],
      'look up the commit for the ref $ref',
      workingDirectory: (await checkoutDirectory).path,
    );
    assert(revisionHash.isNotEmpty);
    return revisionHash;
  }

  /// Determines if one ref is an ancestor for another.
  Future<bool> isAncestor(String possibleAncestor, String possibleDescendant) async {
    final int exitcode = await git.run(
      <String>[
        'merge-base',
        '--is-ancestor',
        possibleDescendant,
        possibleAncestor
      ],
      'verify $possibleAncestor is a direct ancestor of $possibleDescendant.',
      allowNonZeroExitCode: true,
      workingDirectory: (await checkoutDirectory).path,
    );
    return exitcode == 0;
  }

  /// Determines if a given commit has a tag.
  Future<bool> isCommitTagged(String commit) async {
    final int exitcode = await git.run(
      <String>['describe', '--exact-match', '--tags', commit],
      'verify $commit is already tagged',
      allowNonZeroExitCode: true,
      workingDirectory: (await checkoutDirectory).path,
    );
    return exitcode == 0;
  }

  /// Determines if a commit will cherry-pick to current HEAD without conflict.
  Future<bool> canCherryPick(String commit) async {
    assert(
      await gitCheckoutClean(),
      'cannot cherry-pick because git checkout ${(await checkoutDirectory).path} is not clean',
    );

    final int exitcode = await git.run(
      <String>['cherry-pick', '--no-commit', commit],
      'attempt to cherry-pick $commit without committing',
      allowNonZeroExitCode: true,
      workingDirectory: (await checkoutDirectory).path,
    );

    final bool result = exitcode == 0;

    if (result == false) {
      stdio.printError(await git.getOutput(
        <String>['diff'],
        'get diff of failed cherry-pick',
        workingDirectory: (await checkoutDirectory).path,
      ));
    }

    await reset('HEAD');
    return result;
  }

  /// Cherry-pick a [commit] to the current HEAD.
  ///
  /// This method will throw a [GitException] if the command fails.
  Future<void> cherryPick(String commit) async {
    assert(
      await gitCheckoutClean(),
      'cannot cherry-pick because git checkout ${(await checkoutDirectory).path} is not clean',
    );

    await git.run(
      <String>['cherry-pick', commit],
      'cherry-pick $commit',
      workingDirectory: (await checkoutDirectory).path,
    );
  }

  /// Resets repository HEAD to [ref].
  Future<void> reset(String ref) async {
    await git.run(
      <String>['reset', ref, '--hard'],
      'reset to $ref',
      workingDirectory: (await checkoutDirectory).path,
    );
  }

  /// Push [commit] to the release channel [branch].
  Future<void> pushRef({
    required String fromRef,
    required String remote,
    required String toRef,
    bool force = false,
    bool dryRun = false,
  }) async {
    final List<String> args = <String>[
      'push',
      if (force) '--force',
      remote,
      '$fromRef:$toRef',
    ];
    final String command = <String>[
      'git',
      ...args,
    ].join(' ');
    if (dryRun) {
      stdio.printStatus('About to execute command: `$command`');
    } else {
      await git.run(
        args,
        'update the release branch with the commit',
        workingDirectory: (await checkoutDirectory).path,
      );
      stdio.printStatus('Executed command: `$command`');
    }
  }

  Future<String> commit(
    String message, {
    bool addFirst = false,
  }) async {
    assert(!message.contains("'"));
    final bool hasChanges = (await git.getOutput(
      <String>['status', '--porcelain'],
      'check for uncommitted changes',
      workingDirectory: (await checkoutDirectory).path,
    )).trim().isNotEmpty;
    if (!hasChanges) {
      throw ConductorException(
          'Tried to commit with message $message but no changes were present');
    }
    if (addFirst) {
      await git.run(
        <String>['add', '--all'],
        'add all changes to the index',
        workingDirectory: (await checkoutDirectory).path,
      );
    }
    await git.run(
      <String>['commit', "--message='$message'"],
      'commit changes',
      workingDirectory: (await checkoutDirectory).path,
    );
    return reverseParse('HEAD');
  }

  /// Create an empty commit and return the revision.
  @visibleForTesting
  Future<String> authorEmptyCommit([String message = 'An empty commit']) async {
    await git.run(
      <String>[
        '-c',
        'user.name=Conductor',
        '-c',
        'user.email=conductor@flutter.dev',
        'commit',
        '--allow-empty',
        '-m',
        "'$message'",
      ],
      'create an empty commit',
      workingDirectory: (await checkoutDirectory).path,
    );
    return reverseParse('HEAD');
  }

  /// Create a new clone of the current repository.
  ///
  /// The returned repository will inherit all properties from this one, except
  /// for the upstream, which will be the path to this repository on disk.
  ///
  /// This method is for testing purposes.
  @visibleForTesting
  Future<Repository> cloneRepository(String cloneName);
}

class FrameworkRepository extends Repository {
  FrameworkRepository(
    this.checkouts, {
    String name = 'framework',
    Remote upstreamRemote = const Remote(
        name: RemoteName.upstream, url: FrameworkRepository.defaultUpstream),
    bool localUpstream = false,
    String? previousCheckoutLocation,
    String? initialRef,
    Remote? mirrorRemote,
  }) : super(
          name: name,
          upstreamRemote: upstreamRemote,
          mirrorRemote: mirrorRemote,
          initialRef: initialRef,
          fileSystem: checkouts.fileSystem,
          localUpstream: localUpstream,
          parentDirectory: checkouts.directory,
          platform: checkouts.platform,
          processManager: checkouts.processManager,
          stdio: checkouts.stdio,
          previousCheckoutLocation: previousCheckoutLocation,
        );

  /// A [FrameworkRepository] with the host conductor's repo set as upstream.
  ///
  /// This is useful when testing a commit that has not been merged upstream
  /// yet.
  factory FrameworkRepository.localRepoAsUpstream(
    Checkouts checkouts, {
    String name = 'framework',
    String? previousCheckoutLocation,
    required String upstreamPath,
  }) {
    return FrameworkRepository(
      checkouts,
      name: name,
      upstreamRemote: Remote(
        name: RemoteName.upstream,
        url: 'file://$upstreamPath/',
      ),
      previousCheckoutLocation: previousCheckoutLocation,
    );
  }

  final Checkouts checkouts;
  static const String defaultUpstream =
      'git@github.com:flutter/flutter.git';

  static const String defaultBranch = 'master';

  Future<CiYaml> get ciYaml async {
    final CiYaml ciYaml =
        CiYaml((await checkoutDirectory).childFile('.ci.yaml'));
    return ciYaml;
  }

  Future<String> get cacheDirectory async {
    return fileSystem.path.join(
      (await checkoutDirectory).path,
      'bin',
      'cache',
    );
  }

  /// Tag [commit] and push the tag to the remote.
  Future<void> tag(String commit, String tagName, String remote) async {
    assert(commit.isNotEmpty);
    assert(tagName.isNotEmpty);
    assert(remote.isNotEmpty);
    stdio.printStatus('About to tag commit $commit as $tagName...');
    await git.run(
      <String>['tag', tagName, commit],
      'tag the commit with the version label',
      workingDirectory: (await checkoutDirectory).path,
    );
    stdio.printStatus('Tagging successful.');
    stdio.printStatus('About to push $tagName to remote $remote...');
    await git.run(
      <String>['push', remote, tagName],
      'publish the tag to the repo',
      workingDirectory: (await checkoutDirectory).path,
    );
    stdio.printStatus('Tag push successful.');
  }

  @override
  Future<Repository> cloneRepository(String? cloneName) async {
    assert(localUpstream);
    cloneName ??= 'clone-of-$name';
    return FrameworkRepository(
      checkouts,
      name: cloneName,
      upstreamRemote: Remote(
          name: RemoteName.upstream,
          url: 'file://${(await checkoutDirectory).path}/'),
    );
  }

  Future<void> _ensureToolReady() async {
    final File toolsStamp = fileSystem
        .directory(await cacheDirectory)
        .childFile('flutter_tools.stamp');
    if (toolsStamp.existsSync()) {
      final String toolsStampHash = toolsStamp.readAsStringSync().trim();
      final String repoHeadHash = await reverseParse('HEAD');
      if (toolsStampHash == repoHeadHash) {
        return;
      }
    }

    stdio.printTrace('Building tool...');
    // Build tool
    await processManager.run(<String>[
      fileSystem.path.join((await checkoutDirectory).path, 'bin', 'flutter'),
      'help',
    ]);
  }

  Future<io.ProcessResult> runFlutter(List<String> args) async {
    await _ensureToolReady();
    return processManager.run(<String>[
      fileSystem.path.join((await checkoutDirectory).path, 'bin', 'flutter'),
      ...args,
    ]);
  }

  @override
  Future<void> checkout(String ref) async {
    await super.checkout(ref);
    // The tool will overwrite old cached artifacts, but not delete unused
    // artifacts from a previous version. Thus, delete the entire cache and
    // re-populate.
    final Directory cache = fileSystem.directory(await cacheDirectory);
    if (cache.existsSync()) {
      stdio.printTrace('Deleting cache...');
      cache.deleteSync(recursive: true);
    }
    await _ensureToolReady();
  }

  Future<Version> flutterVersion() async {
    // Check version
    final io.ProcessResult result =
        await runFlutter(<String>['--version', '--machine']);
    final Map<String, dynamic> versionJson = jsonDecode(
      stdoutToString(result.stdout),
    ) as Map<String, dynamic>;
    return Version.fromString(versionJson['frameworkVersion'] as String);
  }

  /// Update this framework's engine version file.
  ///
  /// Returns [true] if the version file was updated and a commit is needed.
  Future<bool> updateEngineRevision(
    String newEngine, {
    @visibleForTesting File? engineVersionFile,
  }) async {
    assert(newEngine.isNotEmpty);
    engineVersionFile ??= (await checkoutDirectory)
        .childDirectory('bin')
        .childDirectory('internal')
        .childFile('engine.version');
    assert(engineVersionFile.existsSync());
    final String oldEngine = engineVersionFile.readAsStringSync();
    if (oldEngine.trim() == newEngine.trim()) {
      stdio.printTrace(
        'Tried to update the engine revision but version file is already up to date at: $newEngine',
      );
      return false;
    }
    stdio.printStatus('Updating engine revision from $oldEngine to $newEngine');
    engineVersionFile.writeAsStringSync(
      // Version files have trailing newlines
      '${newEngine.trim()}\n',
      flush: true,
    );
    return true;
  }
}

/// A wrapper around the host repository that is executing the conductor.
///
/// [Repository] methods that mutate the underlying repository will throw a
/// [ConductorException].
class HostFrameworkRepository extends FrameworkRepository {
  HostFrameworkRepository({
    required Checkouts checkouts,
    String name = 'host-framework',
    required String upstreamPath,
  }) : super(
          checkouts,
          name: name,
          upstreamRemote: Remote(
            name: RemoteName.upstream,
            url: 'file://$upstreamPath/',
          ),
          localUpstream: false,
        ) {
    _checkoutDirectory = checkouts.fileSystem.directory(upstreamPath);
  }

  @override
  Future<Directory> get checkoutDirectory async => _checkoutDirectory!;

  @override
  Future<void> newBranch(String branchName) async {
    throw ConductorException(
        'newBranch not implemented for the host repository');
  }

  @override
  Future<void> checkout(String ref) async {
    throw ConductorException(
        'checkout not implemented for the host repository');
  }

  @override
  Future<String> cherryPick(String commit) async {
    throw ConductorException(
        'cherryPick not implemented for the host repository');
  }

  @override
  Future<String> reset(String ref) async {
    throw ConductorException('reset not implemented for the host repository');
  }

  @override
  Future<void> tag(String commit, String tagName, String remote) async {
    throw ConductorException('tag not implemented for the host repository');
  }

  void updateChannel(
    String commit,
    String remote,
    String branch, {
    bool force = false,
    bool dryRun = false,
  }) {
    throw ConductorException(
        'updateChannel not implemented for the host repository');
  }

  @override
  Future<String> authorEmptyCommit([String message = 'An empty commit']) async {
    throw ConductorException(
      'authorEmptyCommit not implemented for the host repository',
    );
  }
}

class EngineRepository extends Repository {
  EngineRepository(
    this.checkouts, {
    String name = 'engine',
    String initialRef = EngineRepository.defaultBranch,
    Remote upstreamRemote = const Remote(
        name: RemoteName.upstream, url: EngineRepository.defaultUpstream),
    bool localUpstream = false,
    String? previousCheckoutLocation,
    Remote? mirrorRemote,
  }) : super(
          name: name,
          upstreamRemote: upstreamRemote,
          mirrorRemote: mirrorRemote,
          initialRef: initialRef,
          fileSystem: checkouts.fileSystem,
          localUpstream: localUpstream,
          parentDirectory: checkouts.directory,
          platform: checkouts.platform,
          processManager: checkouts.processManager,
          stdio: checkouts.stdio,
          previousCheckoutLocation: previousCheckoutLocation,
        );

  final Checkouts checkouts;

  Future<CiYaml> get ciYaml async {
    final CiYaml ciYaml = CiYaml((await checkoutDirectory).childFile('.ci.yaml'));
    return ciYaml;
  }

  static const String defaultUpstream = 'git@github.com:flutter/engine.git';
  static const String defaultBranch = 'master';

  /// Update the `dart_revision` entry in the DEPS file.
  Future<void> updateDartRevision(
    String newRevision, {
    @visibleForTesting File? depsFile,
  }) async {
    assert(newRevision.length == 40);
    depsFile ??= (await checkoutDirectory).childFile('DEPS');
    final String fileContent = depsFile.readAsStringSync();
    final RegExp dartPattern = RegExp("[ ]+'dart_revision': '([a-z0-9]{40})',");
    final Iterable<RegExpMatch> allMatches =
        dartPattern.allMatches(fileContent);
    if (allMatches.length != 1) {
      throw ConductorException(
          'Unexpected content in the DEPS file at ${depsFile.path}\n'
          'Expected to find pattern ${dartPattern.pattern} 1 times, but got '
          '${allMatches.length}.');
    }
    final String updatedFileContent = fileContent.replaceFirst(
      dartPattern,
      "  'dart_revision': '$newRevision',",
    );

    depsFile.writeAsStringSync(updatedFileContent, flush: true);
  }

  @override
  Future<Repository> cloneRepository(String? cloneName) async {
    assert(localUpstream);
    cloneName ??= 'clone-of-$name';
    return EngineRepository(
      checkouts,
      name: cloneName,
      upstreamRemote: Remote(
          name: RemoteName.upstream,
          url: 'file://${(await checkoutDirectory).path}/'),
    );
  }
}

/// An enum of all the repositories that the Conductor supports.
enum RepositoryType {
  framework,
  engine,
}

class Checkouts {
  Checkouts({
    required this.fileSystem,
    required this.platform,
    required this.processManager,
    required this.stdio,
    required Directory parentDirectory,
    String directoryName = 'flutter_conductor_checkouts',
  }) : directory = parentDirectory.childDirectory(directoryName) {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }

  final Directory directory;
  final FileSystem fileSystem;
  final Platform platform;
  final ProcessManager processManager;
  final Stdio stdio;
}

class CiYaml {
  CiYaml(this.file) {
    if (!file.existsSync()) {
      throw ConductorException('Could not find the .ci.yaml file at ${file.path}');
    }
  }

  /// Underlying [File] that this object wraps.
  final File file;

  /// Returns the raw string contents of this file.
  ///
  /// This is not cached as the contents can be written to while the conductor
  /// is running.
  String get stringContents => file.readAsStringSync();

  /// Returns the parsed contents of the file as a [YamlMap].
  ///
  /// This is not cached as the contents can be written to while the conductor
  /// is running.
  YamlMap get contents => loadYaml(stringContents) as YamlMap;

  List<String> get enabledBranches {
    final YamlList yamlList = contents['enabled_branches'] as YamlList;
    return yamlList.map<String>((dynamic element) {
      return element as String;
    }).toList();
  }

  static final RegExp _enabledBranchPattern = RegExp(r'enabled_branches:');

  /// Update this .ci.yaml file with the given branch name.
  ///
  /// The underlying [File] is written to, but not committed to git. This method
  /// will throw a [ConductorException] if the [branchName] is already present
  /// in the file or if the file does not have an "enabled_branches:" field.
  void enableBranch(String branchName) {
    final List<String> newStrings = <String>[];
    if (enabledBranches.contains(branchName)) {
      throw ConductorException('${file.path} already contains the branch $branchName');
    }
    if (!_enabledBranchPattern.hasMatch(stringContents)) {
      throw ConductorException(
        'Did not find the expected string "enabled_branches:" in the file ${file.path}',
      );
    }
    final List<String> lines = stringContents.split('\n');
    bool insertedCurrentBranch = false;
    for (final String line in lines) {
      // Every existing line should be copied to the new Yaml
      newStrings.add(line);
      if (insertedCurrentBranch) {
        continue;
      }
      if (_enabledBranchPattern.hasMatch(line)) {
        insertedCurrentBranch = true;
        // Indent two spaces
        final String indent = ' ' * 2;
        newStrings.add('$indent- ${branchName.trim()}');
      }
    }
    file.writeAsStringSync(newStrings.join('\n'), flush: true);
  }
}
