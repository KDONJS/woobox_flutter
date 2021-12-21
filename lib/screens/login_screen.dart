import 'dart:ui';

import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/signup_screen.dart';
import 'package:WooBox/service/LoginService.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/social_icons.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  LoginScreen({Key key}) : super(key: key);

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  Color primaryColor;
  var passwordVisible = false;
  var isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    void socialLogin(req) async {
      setState(() {
        isLoading = true;
      });
      await socialLoginApi(req).then((res) async {
        if (!mounted) return;
        await getCustomer(res['user_id']).then((response) {
          if (!mounted) return;
          setInt(USER_ID, res['user_id']);
          setString(FIRST_NAME, response['first_name']);
          setString(LAST_NAME, response['last_name']);
          setString(USER_EMAIL, res['user_email']);
          setString(USERNAME, res['user_nicename']);
          setString(TOKEN, res['token']);
          setString(AVATAR, res['avatar']);
          setString(USER_DISPLAY_NAME, res['user_display_name']);
          setString(PASSWORD, req['token']);
          setBool(IS_LOGGED_IN, true);
          setBool(IS_SOCIAL_LOGIN, true);
          setString(AVATAR, req['photoURL']);
          setState(() {
            isLoading = false;
          });
          launchNewScreenWithNewTask(context, HomeScreen.tag);
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
          toast(error.toString());
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        toast(error.toString());
      });
    }

    void onFacebookSignInTap() async {
      await LoginService().getFacebookSignInData().then((res) {
        socialLogin(res);
      }).catchError((error) {
        toast(error);
      });
    }

    void onGoogleSignInTap() async {
      await LoginService().getGoogleSignInData().then((res) {
        socialLogin(res);
      }).catchError((error) {
        print('Google SignIn Error: $error');
        toast(error.toString());
      });
    }

    Widget logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: Image.asset('assets/ic_launcher.png', height: 200, width: 200),
      ),
    );

    Widget email = TextFormField(
      controller: emailCont,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
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
      controller: passwordCont,
      obscureText: !passwordVisible,
      decoration: InputDecoration(
          filled: true,
          fillColor: editTextBackgroundColor,
          focusColor: editTextFocusedColor,
          hintText: AppLocalizations.of(context).translate('password'),
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          border: textFiledBorderStyle,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                print(passwordVisible);
                passwordVisible ? passwordVisible = false : passwordVisible = true;
              });
            },
            icon: passwordVisible ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
          )),
    );

    Widget loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: MaterialButton(
        height: materialButtonHeight,
        shape: roundedRectangleBorder(20),
        onPressed: () {
          hideKeyboard(context);
          var request = {"username": "${emailCont.text}", "password": "${passwordCont.text}"};
          var r = login(request);
          if (!mounted) return;
          setState(() {
            isLoading = true;
          });
          if (r.then((res) {
                getCustomer(res.user_id).then((response) {
                  if (!mounted) return;
                  setInt(USER_ID, res.user_id);
                  setString(FIRST_NAME, response['first_name']);
                  setString(LAST_NAME, response['last_name']);
                  setString(USER_EMAIL, res.user_email);
                  setString(USERNAME, res.user_nicename);
                  setString(TOKEN, res.token);
                  setString(AVATAR, res.avatar);
                  setString(PROFILE_IMAGE, res.profile_image);
                  setString(USER_DISPLAY_NAME, res.user_display_name);
                  setString(PASSWORD, passwordCont.text);
                  setBool(IS_LOGGED_IN, true);
                  setBool(IS_SOCIAL_LOGIN, false);
                  setState(() {
                    isLoading = false;
                  });
                  launchNewScreenWithNewTask(context, HomeScreen.tag);
                }).catchError((error) {});
              }).catchError((errorMsg) {
                toast(errorMsg.toString());
                setState(() {
                  isLoading = false;
                });
              }) !=
              null) {}
        },
        color: primaryColor,
        child: Text(AppLocalizations.of(context).translate('login'), style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );

    Widget signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: MaterialButton(
        height: materialButtonHeight,
        shape: roundedRectangleBorder(20),
        onPressed: () => launchNewScreen(context, SignUpScreen.tag),
        color: Colors.white,
        child: Text(AppLocalizations.of(context).translate('signup'), style: TextStyle(color: primaryColor, fontSize: 20)),
      ),
    );

    Widget forgotLabel = FlatButton(
      child: Text(
        AppLocalizations.of(context).translate('forgot_password'),
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    Widget lblSignInWith = Text(AppLocalizations.of(context).translate('sign_in_with'), style: boldFonts(size: 18));

    Widget socialButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
            shape: roundedRectangleBorder(20), onPressed: () => onFacebookSignInTap(), padding: EdgeInsets.all(8), color: facebookColor, child: Icon(SocialIcons.facebook, color: Colors.white)),
        SizedBox(width: 10),
        MaterialButton(
            shape: roundedRectangleBorder(20), onPressed: () => onGoogleSignInTap(), padding: EdgeInsets.all(8), color: googleSignInColor, child: Icon(SocialIcons.google, color: Colors.white)),
        /*MaterialButton(
            shape: roundedRectangleBorder(20),
            onPressed: () {
              launchNewScreen(context, HomeScreen.tag);
            },
            padding: EdgeInsets.all(8),
            color: twitterColor,
            child: Icon(SocialIcons.twitter, color: Colors.white))*/
      ],
    );

    return new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/ic_app_background.png'),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Center(
            child: Stack(
              children: <Widget>[
                Center(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      logo,
                      SizedBox(height: 48.0),
                      email,
                      SizedBox(height: 8.0),
                      password,
                      SizedBox(height: 20.0),
                      loginButton,
                      SizedBox(height: 8.0),
                      signUpButton,
                      //TODO Update in next build
                      //forgotLabel,
                      SizedBox(height: 30),
                      Center(child: lblSignInWith),
                      SizedBox(height: 10.0),
                      socialButtons
                    ],
                  ),
                ),
                isLoading
                    ? Container(
                        child: CircularProgressIndicator(),
                        alignment: Alignment.center,
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
