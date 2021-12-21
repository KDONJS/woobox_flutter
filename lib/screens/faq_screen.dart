import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/utils/common.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  static String tag = '/FAQScreen';

  @override
  FAQScreenState createState() => FAQScreenState();
}

class FAQScreenState extends State<FAQScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('faq')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ExpandablePanel(
              tapHeaderToExpand: true,
              collapsed: Text(AppLocalizations.of(context).translate('account_deactivate'), style: boldFonts(size: 18)),
              expanded: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('account_deactivate'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('quick_pay'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('return_items'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('replace_items'), style: boldFonts())
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ExpandablePanel(
              collapsed: Text(AppLocalizations.of(context).translate('quick_pay'), style: boldFonts(size: 18)),
              expanded: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('account_deactivate'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('quick_pay'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('return_items'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('replace_items'), style: boldFonts())
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ExpandablePanel(
              collapsed: Text(AppLocalizations.of(context).translate('return_items'), style: boldFonts(size: 18)),
              expanded: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('account_deactivate'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('quick_pay'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('return_items'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('replace_items'), style: boldFonts())
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ExpandablePanel(
              collapsed: Text(AppLocalizations.of(context).translate('replace_items'), style: boldFonts(size: 18)),
              expanded: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate('account_deactivate'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('quick_pay'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('return_items'), style: boldFonts()),
                  Text(AppLocalizations.of(context).translate('replace_items'), style: boldFonts())
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
