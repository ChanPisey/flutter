// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/memory.dart';
import 'package:file_testing/file_testing.dart';
import 'package:flutter_tools/src/base/file_system.dart';
import 'package:flutter_tools/src/base/io.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/base/os.dart';
import 'package:flutter_tools/src/base/platform.dart';
import 'package:flutter_tools/src/base/terminal.dart';
import 'package:flutter_tools/src/cache.dart';
import 'package:test/fake.dart';

import '../src/common.dart';
<<<<<<< HEAD
import '../src/mocks.dart';
=======
import '../src/fake_http_client.dart';
import '../src/fakes.dart';
>>>>>>> 77d935af4db863f6abd0b9c31c7e6df2a13de57b

final Platform testPlatform = FakePlatform();

void main() {
  testWithoutContext('ArtifactUpdater can download a zip archive', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    );
    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), exists);
  });

<<<<<<< HEAD
  testWithoutContext('ArtifactUpdater will restart the status ticker if it needs to retry the download', () async {
    final MockOperatingSystemUtils operatingSystemUtils = MockOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final Logger logger = StdoutLogger(
      terminal: Terminal.test(supportsColor: true),
      stdio: MockStdio(),
      outputPreferences: OutputPreferences.test(),
      timeoutConfiguration: const TimeoutConfiguration(),
=======
  testWithoutContext('ArtifactUpdater can download a zip archive and delete stale files', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );
    // Unrelated file from another cache.
    fileSystem.file('out/bar').createSync(recursive: true);
    // Stale file from current cache.
    fileSystem.file('out/test/foo.txt').createSync(recursive: true);

    await artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    );
    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), exists);
    expect(fileSystem.file('out/bar'), exists);
    expect(fileSystem.file('out/test/foo.txt'), isNot(exists));
  });

  testWithoutContext('ArtifactUpdater will not validate the md5 hash if the '
    'x-goog-hash header is present but missing an md5 entry', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();

    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.list(<FakeRequest>[
        FakeRequest(Uri.parse('http://test.zip'), response: const FakeResponse(
          headers: <String, List<String>>{
            'x-goog-hash': <String>[],
          }
        )),
      ]),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    );
    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), exists);
  });

  testWithoutContext('ArtifactUpdater will validate the md5 hash if the '
    'x-goog-hash header is present', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();

    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.list(<FakeRequest>[
        FakeRequest(Uri.parse('http://test.zip'), response: const FakeResponse(
          body: <int>[0],
          headers: <String, List<String>>{
            'x-goog-hash': <String>[
              'foo-bar-baz',
              'md5=k7iFrf4NoInN9jSQT9WfcQ=='
            ],
          }
        )),
      ]),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    );
    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), exists);
  });

  testWithoutContext('ArtifactUpdater will validate the md5 hash if the '
    'x-goog-hash header is present and throw if it does not match', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();

    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.list(<FakeRequest>[
         FakeRequest(Uri.parse('http://test.zip'), response: const FakeResponse(
           body: <int>[0],
           headers: <String, List<String>>{
             'x-goog-hash': <String>[
              'foo-bar-baz',
              'md5=k7iFrf4SQT9WfcQ=='
            ],
          }
        )),
       FakeRequest(Uri.parse('http://test.zip'), response: const FakeResponse(
           headers: <String, List<String>>{
             'x-goog-hash': <String>[
              'foo-bar-baz',
              'md5=k7iFrf4SQT9WfcQ=='
            ],
          }
        )),
      ]),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await expectLater(() async => artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    ), throwsToolExit(message: 'k7iFrf4SQT9WfcQ==')); // validate that the hash mismatch message is included.
  });

  testWithoutContext('ArtifactUpdater will restart the status ticker if it needs to retry the download', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final Logger logger = StdoutLogger(
      terminal: Terminal.test(supportsColor: true),
      stdio: FakeStdio(),
      outputPreferences: OutputPreferences.test(),
>>>>>>> 77d935af4db863f6abd0b9c31c7e6df2a13de57b
    );
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
<<<<<<< HEAD
      httpClient: MockHttpClient()..exceptionOnFirstRun = true,
=======
      httpClient: FakeHttpClient.list(<FakeRequest>[
        FakeRequest(Uri.parse('http://test.zip'), responseError: const HttpException('')),
        FakeRequest(Uri.parse('http://test.zip')),
      ]),
>>>>>>> 77d935af4db863f6abd0b9c31c7e6df2a13de57b
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await artifactUpdater.downloadZipArchive(
      'test message',
<<<<<<< HEAD
      Uri.parse('http:///test.zip'),
=======
      Uri.parse('http://test.zip'),
>>>>>>> 77d935af4db863f6abd0b9c31c7e6df2a13de57b
      fileSystem.currentDirectory.childDirectory('out'),
    );

    expect(fileSystem.file('out/test'), exists);
  });

  testWithoutContext('ArtifactUpdater will re-attempt on a non-200 response', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();

    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.list(<FakeRequest>[
        FakeRequest(Uri.parse('http://test.zip'), response: const FakeResponse(statusCode: HttpStatus.preconditionFailed)),
        FakeRequest(Uri.parse('http://test.zip'), response: const FakeResponse(statusCode: HttpStatus.preconditionFailed)),
      ]),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await expectLater(() async => artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    ), throwsToolExit());

    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), isNot(exists));
  });

  testWithoutContext('ArtifactUpdater will tool exit on an ArgumentError from http client with base url override', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: FakePlatform(
        environment: <String, String>{
          'FLUTTER_STORAGE_BASE_URL': 'foo-bar'
        },
      ),
      httpClient: FakeHttpClient.list(<FakeRequest>[
        FakeRequest(Uri.parse('http:///foo-bar/test.zip'), responseError: ArgumentError())
      ]),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await expectLater(() async => artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http:///foo-bar/test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    ), throwsToolExit());

    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), isNot(exists));
  });

  testWithoutContext('ArtifactUpdater will rethrow on an ArgumentError from http client without base url override', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.list(<FakeRequest>[
        FakeRequest(Uri.parse('http://test.zip'), responseError: ArgumentError()),
      ]),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await expectLater(() async => artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    ), throwsArgumentError);

    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), isNot(exists));
  });

  testWithoutContext('ArtifactUpdater will re-download a file if unzipping fails', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );
    operatingSystemUtils.failures = 1;

    await artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    );
    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), exists);
  });

  testWithoutContext('ArtifactUpdater will de-download a file if unzipping fails on windows', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils(windows: true);
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );
    operatingSystemUtils.failures = 1;

    await artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    );
    expect(logger.statusText, contains('test message'));
    expect(fileSystem.file('out/test'), exists);
  });

  testWithoutContext('ArtifactUpdater will bail with a tool exit if unzipping fails more than twice', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );
    operatingSystemUtils.failures = 2;

    expect(artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    ), throwsToolExit());
    expect(fileSystem.file('te,[/test'), isNot(exists));
    expect(fileSystem.file('out/test'), isNot(exists));
  });

  testWithoutContext('ArtifactUpdater will bail if unzipping fails more than twice on Windows', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils(windows: true);
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );
    operatingSystemUtils.failures = 2;

    expect(artifactUpdater.downloadZipArchive(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    ), throwsToolExit());
    expect(fileSystem.file('te,[/test'), isNot(exists));
    expect(fileSystem.file('out/test'), isNot(exists));
  });

  testWithoutContext('ArtifactUpdater can download a tar archive', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    await artifactUpdater.downloadZippedTarball(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    );
    expect(fileSystem.file('out/test'), exists);
  });

  testWithoutContext('ArtifactUpdater will delete downloaded files if they exist.', () async {
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test();
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: testPlatform,
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    artifactUpdater.downloadedFiles.addAll(<File>[
      fileSystem.file('a/b/c/d')..createSync(recursive: true),
      fileSystem.file('d/e/f'),
    ]);

    artifactUpdater.removeDownloadedFiles();

    expect(fileSystem.file('a/b/c/d'), isNot(exists));
    expect(logger.errorText, isEmpty);
  });

  testWithoutContext('ArtifactUpdater will tool exit if deleting the existing artifacts fails with 32 on windows', () async {
    const int kSharingViolation = 32;
    final FileExceptionHandler handler = FileExceptionHandler();
    final FakeOperatingSystemUtils operatingSystemUtils = FakeOperatingSystemUtils();
    final MemoryFileSystem fileSystem = MemoryFileSystem.test(opHandle: handler.opHandle);
    final BufferLogger logger = BufferLogger.test();
    final ArtifactUpdater artifactUpdater = ArtifactUpdater(
      fileSystem: fileSystem,
      logger: logger,
      operatingSystemUtils: operatingSystemUtils,
      platform: FakePlatform(operatingSystem: 'windows'),
      httpClient: FakeHttpClient.any(),
      tempStorage: fileSystem.currentDirectory.childDirectory('temp')
        ..createSync(),
    );

    final Directory errorDirectory = fileSystem.currentDirectory
      .childDirectory('out')
      .childDirectory('test')
      ..createSync(recursive: true);
    handler.addError(errorDirectory, FileSystemOp.delete, const FileSystemException('', '', OSError('', kSharingViolation)));

    await expectLater(() async => artifactUpdater.downloadZippedTarball(
      'test message',
      Uri.parse('http://test.zip'),
      fileSystem.currentDirectory.childDirectory('out'),
    ), throwsToolExit(
      message: 'Failed to delete /out/test because the local file/directory is in use by another process'
    ));
    expect(fileSystem.file('out/test'), isNot(exists));
  });
}

class FakeOperatingSystemUtils extends Fake implements OperatingSystemUtils {
  FakeOperatingSystemUtils({this.windows = false});

  int failures = 0;
  final bool windows;

  @override
  void unzip(File file, Directory targetDirectory) {
    if (failures > 0) {
      failures -= 1;
      throw Exception();
    }
    targetDirectory.childFile(file.fileSystem.path.basenameWithoutExtension(file.path))
      .createSync();
  }

  @override
  void unpack(File gzippedTarFile, Directory targetDirectory) {
    if (failures > 0) {
      failures -= 1;
      throw Exception();
    }
    targetDirectory.childFile(gzippedTarFile.fileSystem.path.basenameWithoutExtension(gzippedTarFile.path))
      .createSync();
  }
}
<<<<<<< HEAD

class MockHttpClient extends Mock implements HttpClient {
  int attempts = 0;
  bool argumentError = false;
  bool exceptionOnFirstRun = false;
  final MockHttpClientRequest testRequest = MockHttpClientRequest();

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    if (exceptionOnFirstRun && attempts == 0) {
      attempts += 1;
      throw Exception();
    }
    attempts += 1;
    if (argumentError) {
      throw ArgumentError();
    }
    return testRequest;
  }
}
class MockHttpClientRequest extends Mock implements HttpClientRequest {
  final MockHttpClientResponse testResponse = MockHttpClientResponse();

  @override
  Future<HttpClientResponse> close() async {
    return testResponse;
  }
}
class MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int statusCode = HttpStatus.ok;

  @override
  Future<void> forEach(void Function(List<int> element) action) async {
    return;
  }
}
=======
>>>>>>> 77d935af4db863f6abd0b9c31c7e6df2a13de57b
