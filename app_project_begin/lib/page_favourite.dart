import 'package:flutter/material.dart';

class Favourrite extends StatelessWidget {
  const Favourrite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
    );
  }
}
