import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class AboutScreen extends StatefulWidget {
  static String tag = '/AboutScreen';

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  SharedPreferences pref;
  var primaryColor;
  var darkMode = false;
  PackageInfo package;
  var copyrightText = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    pref = await getSharedPref();
    primaryColor = await getThemeColor();
    package = await PackageInfo.fromPlatform();
    setState(() {
      if (pref.getString(COPYRIGHT_TEXT) != null) {
        copyrightText = pref.getString(COPYRIGHT_TEXT);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? darkBgColor : lightBgColor,
      appBar: getAppBar(context, AppLocalizations.of(context).translate('about_us'), color: darkMode ? darkBgColor : lightBgColor, textColor: darkMode ? whiteColor : blackColor),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Column(
              children: <Widget>[
                Container(
                  width: 130,
                  height: 130,
                  margin: EdgeInsets.only(top: 30),
                  decoration: boxDecorationSoftUI(darkMode: darkMode, radius: 10.0),
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.topCenter,
                  child: Image.asset('assets/ic_app_icon.png'),
                ),
                SizedBox(height: 20),
                Text(package.appName, style: boldFonts(size: 35, color: darkMode ? whiteColor : blackColor)),
                SizedBox(height: 30),
                Text(copyrightText, style: boldFonts(size: 20, color: darkMode ? whiteColor : blackColor)),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => redirectUrl(pref.getString(TERMS_AND_CONDITIONS)),
                  child: Text(AppLocalizations.of(context).translate('terms_and_condition'), style: boldFonts(size: 20, color: primaryColor)),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => redirectUrl(pref.getString(PRIVACY_POLICY)),
                  child: Text(AppLocalizations.of(context).translate('privacy_policy'), style: boldFonts(size: 20, color: primaryColor)),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(AppLocalizations.of(context).translate('follow_us'), style: boldFonts(size: 18, color: textSecondaryColor)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: () => redirectUrl('https://wa.me/${pref.getString(WHATSAPP)}'),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: boxDecorationSoftUI(darkMode: darkMode),
                        child: Image.asset('assets/img/whatsapp.png', height: 35, width: 35),
                      ),
                    ),
                    InkWell(
                      onTap: () => redirectUrl(pref.getString(INSTAGRAM)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: boxDecorationSoftUI(darkMode: darkMode),
                        child: Image.asset('assets/img/instagram.png', height: 35, width: 35),
                      ),
                    ),
                    InkWell(
                      onTap: () => redirectUrl(pref.getString(TWITTER)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: boxDecorationSoftUI(darkMode: darkMode),
                        child: Image.asset('assets/img/twitter.png', height: 35, width: 35),
                      ),
                    ),
                    InkWell(
                      onTap: () => redirectUrl(pref.getString(FACEBOOK)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: boxDecorationSoftUI(darkMode: darkMode),
                        child: Image.asset('assets/img/facebook.png', height: 35, width: 35),
                      ),
                    ),
                    InkWell(
                      onTap: () => redirectUrl('tel:${pref.getString(CONTACT)}'),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: boxDecorationSoftUI(darkMode: darkMode),
                        child: Image.asset('assets/img/contact.png', height: 35, width: 35, color: primaryColor),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
