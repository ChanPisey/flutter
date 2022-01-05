import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_project/Colors.dart';
import 'package:app_project/Widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social Buttons Example'),
      ),
      body: ListView(
        children: [
          CustomWidgets.socialButtonRect(
              'Login with Facebook', facebookColor, FontAwesomeIcons.facebookF,
              onTap: () {
                Fluttertoast.showToast(msg: 'I am facebook');
              }),
          CustomWidgets.socialButtonRect(
              'Login with Google', googleColor, FontAwesomeIcons.googlePlusG,
              onTap: () {
                Fluttertoast.showToast(msg: 'I am google');
              }),
          CustomWidgets.socialButtonRect(
              'Login with LinkedIn', linkedinColor, FontAwesomeIcons.linkedinIn,
              onTap: () {
                Fluttertoast.showToast(msg: 'I am linkedin');
              }),
          CustomWidgets.socialButtonRect(
              'Login with Github', githubColor, FontAwesomeIcons.github,
              onTap: () {
                Fluttertoast.showToast(msg: 'I am github');
              }),
          CustomWidgets.socialButtonRect(
              'Whatsapp Now', whatsappColor, FontAwesomeIcons.whatsapp,
              onTap: () {
                Fluttertoast.showToast(msg: 'I am whatsapp');
              }),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomWidgets.socialButtonCircle(
                    facebookColor, FontAwesomeIcons.facebookF,
                    iconColor: Colors.white, onTap: () {
                  Fluttertoast.showToast(msg: 'I am circle facebook');
                }),
                CustomWidgets.socialButtonCircle(
                    googleColor, FontAwesomeIcons.googlePlusG,
                    iconColor: Colors.white, onTap: () {
                  Fluttertoast.showToast(msg: 'I am circle google');
                }),
                CustomWidgets.socialButtonCircle(
                    whatsappColor, FontAwesomeIcons.whatsapp,
                    iconColor: Colors.white, onTap: () {
                  Fluttertoast.showToast(msg: 'I am circle whatsapp');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}