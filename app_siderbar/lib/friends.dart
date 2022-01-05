import 'package:flutter/material.dart';

// ignore: camel_case_types
class friends extends StatefulWidget {
  const friends({Key? key}) : super(key: key);

  @override
  _friendsState createState() => _friendsState();
}

// ignore: camel_case_types
class _friendsState extends State<friends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
    );
  }
}
