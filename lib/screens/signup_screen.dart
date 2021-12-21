import 'dart:ui';

import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';

  SignUpScreen({Key key}) : super(key: key);

  @override
  _SignUpScreenState createState() => new _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  Color primaryColor;
  var fNameCont = TextEditingController();
  var lNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    primaryColor = await getThemeColor();
    setState(() {});
  }

  signUpApi() async {
    hideKeyboard(context);
    var request = {
      'email': emailCont.text,
      'first_name': fNameCont.text,
      'last_name': lNameCont.text,
      'password': passwordCont.text,
    };
    var id = '';

    createCustomer(id, request).then((res) {
      if (!mounted) return;
      toast(AppLocalizations.of(context).translate('profile_created_success'));
      finish(context);
    }).catchError((error) {
      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: Image.asset('assets/ic_launcher.png', height: 200, width: 200),
      ),
    );

    Widget fName = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: fNameCont,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
          filled: true,
          fillColor: editTextBackgroundColor,
          focusColor: editTextFocusedColor,
          hintText: AppLocalizations.of(context).translate('first_name'),
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          border: textFiledBorderStyle),
    );

    Widget lName = TextFormField(
      keyboardType: TextInputType.text,
      controller: lNameCont,
      textCapitalization: TextCapitalization.words,
      autofocus: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: editTextBackgroundColor,
        focusColor: editTextFocusedColor,
        hintText: AppLocalizations.of(context).translate('last_name'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: emailCont,
      decoration: InputDecoration(
        filled: true,
        fillColor: editTextBackgroundColor,
        focusColor: editTextFocusedColor,
        hintText: AppLocalizations.of(context).translate('Email'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordCont,
      decoration: InputDecoration(
        filled: true,
        fillColor: editTextBackgroundColor,
        focusColor: editTextFocusedColor,
        hintText: AppLocalizations.of(context).translate('password'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: MaterialButton(
        height: materialButtonHeight,
        shape: roundedRectangleBorder(20),
        onPressed: () {
          if (!accessAllowed) {
            toast(demoPurposeMsg);
            return;
          }
          signUpApi();
        },
        color: primaryColor,
        child: Text(AppLocalizations.of(context).translate('signup'), style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );

    Widget loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: MaterialButton(
        height: materialButtonHeight,
        shape: roundedRectangleBorder(20),
        onPressed: () {
          finish(context);
        },
        color: Colors.white,
        child: Text(AppLocalizations.of(context).translate('login'), style: TextStyle(color: primaryColor, fontSize: 20)),
      ),
    );

    return new Scaffold(
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/ic_app_background.png'))),
        alignment: Alignment.bottomCenter,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  logo,
                  SizedBox(height: 48.0),
                  fName,
                  SizedBox(height: 8.0),
                  lName,
                  SizedBox(height: 8.0),
                  email,
                  SizedBox(height: 8.0),
                  password,
                  SizedBox(height: 20.0),
                  SizedBox(child: signUpButton, width: double.infinity),
                  SizedBox(height: 8.0),
                  SizedBox(child: loginButton, width: double.infinity),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
