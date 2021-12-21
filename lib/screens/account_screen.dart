import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/screens/help_center_screen.dart';
import 'package:WooBox/screens/my_offers_screen.dart';
import 'package:WooBox/screens/my_orders_screen.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';

import 'address_manager_screen.dart';
import 'home_screen.dart';

class AccountScreen extends StatefulWidget {
  static String tag = '/AccountScreen';

  @override
  AccountScreenState createState() {
    return AccountScreenState();
  }
}

class AccountScreenState extends State<AccountScreen> {
  var userName = '';
  var list = List<String>();
  Color primaryColor;

  @override
  void initState() {
    super.initState();
    getPref();
    addList(list);
  }

  getPref() async {
    primaryColor = await getThemeColor();
    userName = await getString(USER_DISPLAY_NAME);
    setState(() {});
  }

  handleListClick(index) {
    if (index == 0) {
      launchNewScreen(context, AddressManagerScreen.tag);
    } else if (index == 1) {
      launchNewScreen(context, MyOrdersScreen.tag);
    } else if (index == 2) {
      launchNewScreen(context, MyOffersScreen.tag);
    } else if (index == 3) {
      launchNewScreen(context, HelpCenterScreen.tag);
    }
  }

  logoutClick() async {
    await logout();
    launchNewScreenWithNewTask(context, HomeScreen.tag);
  }

  @override
  Widget build(BuildContext context) {
    final listView = ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (_, index) {
        return GestureDetector(
          onTap: () {
            handleListClick(index);
          },
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: boxDecoration(),
                child: Row(
                  children: <Widget>[Text(list[index], style: boldFonts(size: 16)), Icon(Icons.arrow_forward_ios)],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              )
            ],
          ),
        );
      },
    );

    final body = SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 30),
            CircleAvatar(backgroundColor: Colors.transparent, radius: 60.0, child: Image.asset('assets/ic_profile.png', height: 400, width: 400)),
            SizedBox(height: 10),
            Text(userName, textAlign: TextAlign.center, style: TextStyle(color: blackColor, fontSize: 20)),
            SizedBox(height: 20),
            listView,
            SizedBox(height: 20),
            MaterialButton(
              elevation: 0,
              color: whiteColor,
              shape: roundedRectangleBorder(8, color: primaryColor),
              onPressed: () => logoutClick(),
              child: Text(AppLocalizations.of(context).translate('logout'), style: boldFonts(color: primaryColor)),
            ).visible(userName.isNotEmpty)
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('account')),
      body: body,
    );
  }
}

class CurrencyDropDown extends StatefulWidget {
  static String tag = '/CurrencyDropDown';

  @override
  CurrencyDropDownState createState() => CurrencyDropDownState();
}

class CurrencyDropDownState extends State<CurrencyDropDown> {
  String dropdownValue = defaultCurrency;
  List<String> spinnerItems = [
    '₹',
    '€',
    '\$',
    '£',
  ];

  @override
  void initState() {
    super.initState();
    getDefaultCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.red, fontSize: 18),
      underline: Container(
        height: 2,
        color: viewLineColor,
      ),
      onChanged: (String data) async {
        await setString(DEFAULT_CURRENCY, data);
        setState(() {
          dropdownValue = data;
        });
      },
      items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void getDefaultCurrency() async {
    await getSharedPref().then((pref) {
      setState(() {
        if (pref.get(DEFAULT_CURRENCY) != null) {
          dropdownValue = pref.getString(DEFAULT_CURRENCY);
        } else {
          dropdownValue = defaultCurrency;
        }
        print(dropdownValue);
      });
    });
  }
}
