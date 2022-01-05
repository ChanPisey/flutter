import 'package:flutter/material.dart';
class  My_test extends StatefulWidget {
  _My_test createState() => _My_test();
}

class _My_test extends State<My_test>{
  String _text = "Hello App";
  bool _dark = false;
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: _buildAppBar,

  body: _buildBody,
  );
  }

  get _buildAppBar{
  return AppBar(
    backgroundColor: _dark == true ? Colors.black: Colors.pink,
  title: Text(_text),
    foregroundColor: Colors.black,
    actions: [
     IconButton(onPressed: (){
       setState(() {
         _dark =!_dark;
          // if(_dark == false){
          //   _dark = true;
          // }
          // else {
          //   _dark = false;
          // }
       });
     }, icon: Icon(Icons.refresh))
    ],
  );
  }


  get _buildBody{
  return Container(
    color:  _dark ? Colors.red : Colors.white,
  alignment: Alignment.center,
  child: RaisedButton(
  child: Text("OK"),
  color: Colors.red,
  onPressed: (){
    print("ok");
    setState(() {
      _text = "I LIKE YOU BUT YOU LIKE SOMEONE";

    });

    }

  ),
  );
  }
}

