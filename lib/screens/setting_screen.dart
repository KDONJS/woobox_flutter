import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/LanguageModel.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';

class SettingScreen extends StatefulWidget {
  static String tag = '/SettingScreen';

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  var selectedLanguage = 0;
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    pref = await getSharedPref();
    setState(() {
      selectedLanguage = pref.getInt(SELECTED_LANGUAGE_INDEX) != null ? pref.getInt(SELECTED_LANGUAGE_INDEX) : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(width: 5),
              Image.asset('assets/ic_translate.png', height: 28, width: 28),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(AppLocalizations.of(context).translate('language'), style: boldFonts()),
                ),
              ),
              DropdownButton(
                value: Language.getLanguages()[selectedLanguage].name,
                onChanged: (newValue) {
                  setState(() {
                    for (var i = 0; i < Language.getLanguages().length; i++) {
                      if (newValue == Language.getLanguages()[i].name) {
                        selectedLanguage = i;
                      }
                    }
                    pref.setString(SELECTED_LANGUAGE_CODE, Language.getLanguages()[selectedLanguage].languageCode);
                    pref.setInt(SELECTED_LANGUAGE_INDEX, selectedLanguage);
                    Provider.of<AppState>(context, listen: false).changeLocale(Locale(Language.getLanguages()[selectedLanguage].languageCode, ''));
                    Provider.of<AppState>(context, listen: false).changeLanguageCode(Language.getLanguages()[selectedLanguage].languageCode);
                  });
                },
                items: Language.getLanguages().map((language) {
                  return DropdownMenuItem(
                    child: Row(
                      children: <Widget>[
                        Image.asset(language.flag, width: 24, height: 24),
                        SizedBox(width: 10),
                        Text(language.name),
                      ],
                    ),
                    value: language.name,
                  );
                }).toList(),
              ),
              SizedBox(width: 5),
            ],
          ),
          /*Row(
            children: <Widget>[
              Text('Change Dashboard', style: boldFonts(size: 22))
            ],
          )*/
        ],
      ),
    );
    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('settings')),
      body: body,
    );
  }
}
