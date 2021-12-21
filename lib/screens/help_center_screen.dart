import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/utils/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  static String tag = '/HelpCenterScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          context, AppLocalizations.of(context).translate('help_center')),
      body: Container(),
    );
  }
}
