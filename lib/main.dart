import 'dart:async';
import 'dart:ui';

import 'package:WooBox/app_state.dart';
import 'package:WooBox/screens/about_screen.dart';
import 'package:WooBox/screens/account_screen.dart';
import 'package:WooBox/screens/add_new_address.dart';
import 'package:WooBox/screens/address_manager_screen.dart';
import 'package:WooBox/screens/blog_screen.dart';
import 'package:WooBox/screens/cart_screen.dart';
import 'package:WooBox/screens/faq_screen.dart';
import 'package:WooBox/screens/help_center_screen.dart';
import 'package:WooBox/screens/home_screen.dart';
import 'package:WooBox/screens/login_screen.dart';
import 'package:WooBox/screens/my_offers_screen.dart';
import 'package:WooBox/screens/my_orders_screen.dart';
import 'package:WooBox/screens/order_detail_screen.dart';
import 'package:WooBox/screens/order_summary_screen.dart';
import 'package:WooBox/screens/payment_screen.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/screens/product_review_screen.dart';
import 'package:WooBox/screens/search_screen.dart';
import 'package:WooBox/screens/setting_screen.dart';
import 'package:WooBox/screens/signup_screen.dart';
import 'package:WooBox/screens/view_all_product_screen.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  var pref = await SharedPreferences.getInstance();

  Color color;
  var language;
  try {
    if (pref.getString(THEME_COLOR) == null) {
      color = primaryColor;
    } else {
      color = getColorFromHex(pref.getString(THEME_COLOR));
    }
  } catch (e) {
    color = primaryColor;
  }
  try {
    if (pref.getString(SELECTED_LANGUAGE_CODE) == null) {
      language = 'en';
    } else {
      language = pref.getString(SELECTED_LANGUAGE_CODE);
    }
  } catch (e) {
    language = 'en';
  }
  runApp(MyApp(color, language));
}

class MyApp extends StatefulWidget {
  Color color;
  var language;

  MyApp(this.color, this.language);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //statusBarColor: Colors.white,
      //statusBarIconBrightness: Brightness.dark
    ));*/

    return ChangeNotifierProvider(
      create: (_) => AppState(widget.language, widget.color),
      child: Consumer<AppState>(builder: (context, provider, builder) {
        return MaterialApp(
          title: mAppName,
          debugShowCheckedModeBanner: false,
          supportedLocales: [Locale('en', ''), Locale('fr', ''), Locale('af', ''), Locale('de', ''), Locale('es', ''), Locale('id', ''), Locale('pt', ''), Locale('tr', ''), Locale('hi', '')],
          localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          localeResolutionCallback: (locale, supportedLocales) {
            return Locale(Provider.of<AppState>(context).selectedLanguageCode);
          },
          locale: Provider.of<AppState>(context).locale,
          theme: ThemeData(
            primaryColor: widget.color,
            fontFamily: regularFonts(),
            scaffoldBackgroundColor: whiteColor,
          ),
          home: SplashScreen(),
          routes: <String, WidgetBuilder>{
            LoginScreen.tag: (BuildContext context) => LoginScreen(),
            SearchScreen.tag: (BuildContext context) => SearchScreen(),
            SignUpScreen.tag: (BuildContext context) => SignUpScreen(),
            HomeScreen.tag: (BuildContext context) => HomeScreen(),
            AccountScreen.tag: (BuildContext context) => AccountScreen(),
            MyOffersScreen.tag: (BuildContext context) => MyOffersScreen(),
            HelpCenterScreen.tag: (BuildContext context) => HelpCenterScreen(),
            AddressManagerScreen.tag: (BuildContext context) => AddressManagerScreen(),
            ProductDetail.tag: (BuildContext context) => ProductDetail(product: null),
            OrderDetailScreen.tag: (BuildContext context) => OrderDetailScreen(orderData: null),
            MyOrdersScreen.tag: (BuildContext context) => MyOrdersScreen(),
            ProductReviewScreen.tag: (BuildContext context) => ProductReviewScreen(),
            ViewAllProductScreen.tag: (BuildContext context) => ViewAllProductScreen(),
            OrderSummaryScreen.tag: (BuildContext context) => OrderSummaryScreen(cartList: null),
            FAQScreen.tag: (BuildContext context) => FAQScreen(),
            AddNewAddress.tag: (BuildContext context) => AddNewAddress(),
            PaymentScreen.tag: (BuildContext context) => PaymentScreen(),
            CartScreen.tag: (BuildContext context) => CartScreen(),
            AboutScreen.tag: (BuildContext context) => AboutScreen(),
            BlogScreen.tag: (BuildContext context) => BlogScreen(),
            SettingScreen.tag: (BuildContext context) => SettingScreen(),
          },
        );
      }),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    return Timer(Duration(seconds: 2), () {
      launchNewScreenWithNewTask(context, HomeScreen.tag);
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/ic_app_background.png'))),
        alignment: Alignment.bottomCenter,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset('assets/ic_app_icon.png', height: 150, width: 150),
                SizedBox(height: 10),
                Text(mAppName, style: boldFonts(size: 40), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
