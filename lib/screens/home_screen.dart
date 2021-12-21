import 'dart:convert';

import 'package:WooBox/model/CategoryData.dart';
import 'package:WooBox/model/OrderDataModel.dart';
import 'package:WooBox/model/WishListModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/about_screen.dart';
import 'package:WooBox/screens/account_screen.dart';
import 'package:WooBox/screens/cart_fragment.dart';
import 'package:WooBox/screens/login_screen.dart';
import 'package:WooBox/screens/profile_fragment.dart';
import 'package:WooBox/screens/search_screen.dart';
import 'package:WooBox/screens/setting_screen.dart';
import 'package:WooBox/screens/wishlist_fragment.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';
import 'blog_screen.dart';
import 'category_detail_screen.dart';
import 'faq_screen.dart';
import 'home_fragment.dart';
import 'my_offers_screen.dart';
import 'my_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomePage';

  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var f1 = HomeFragment();
  var f2 = WishListFragment();
  var f3 = CartFragment();
  var f4 = ProfileFragment();

  int mCurrentIndex = 0;
  String appBarTitle = 'Home';
  var userName = '';
  var lblLogin = 'Login';
  String orderCount = '00';
  var mWishListCount = 0;
  var mOrderListModel = List<OrderDataModel>();
  var mCategoryModel = List<CategoryData>();
  var mProfileImage = '';

  List<Widget> viewContainer;
  SharedPreferences pref;
  Color primaryColor;

  @override
  void initState() {
    super.initState();
    viewContainer = [f1, f2, f3, f4];
    getPref();

    getWishList().then((res) {
      if (!mounted) return;
      Iterable list = res;
      var mWishListModel = list.map((model) => WishListModel.fromJson(model)).toList();
      setState(() {
        mWishListCount = mWishListModel.length;
      });
    }).catchError((error) {});
  }

  getPref() async {
    pref = await getSharedPref();
    primaryColor = Theme.of(context).primaryColor;
    setState(() {
      userName = pref.getBool(IS_LOGGED_IN) != null ? pref.getString(FIRST_NAME) + ' ' + pref.getString(LAST_NAME) : '';
      lblLogin = pref.getBool(IS_LOGGED_IN) != null ? AppLocalizations.of(context).translate('logout') : AppLocalizations.of(context).translate('login');
      try {
        if (pref.getBool(IS_LOGGED_IN) != null) {
          orderCount = pref.getInt(ORDER_COUNT).toString();
          orderCount = pref.getInt(ORDER_COUNT) < 10 ? '0$orderCount' : orderCount;
        }
      } catch (e) {
        orderCount = '00';
      }
      mProfileImage = pref.get(PROFILE_IMAGE) != null ? pref.getString(PROFILE_IMAGE) : pref.getString(AVATAR);
    });

    if (pref.getString(CATEGORY_DATA) != null) {
      setState(() {
        Iterable list = jsonDecode(pref.getString(CATEGORY_DATA));
        mCategoryModel = list.map((model) => CategoryData.fromJson(model)).toList();
      });
    }
    await getCategories().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mCategoryModel = list.map((model) => CategoryData.fromJson(model)).toList();
        pref.setString(CATEGORY_DATA, jsonEncode(res));
      });
    });
  }

  checkLogin(context) async {
    var pref = await getSharedPref();
    if (pref.getBool(IS_LOGGED_IN) != null) {
      await logout();
      HomeScreen().launch(context, isNewTask: true);
    } else {
      LoginScreen().launch(context);
    }
  }

  checkLoggedIn(context, tag) async {
    var pref = await getSharedPref();
    if (pref.getBool(IS_LOGGED_IN) != null && pref.getBool(IS_LOGGED_IN)) {
      launchNewScreen(context, tag);
    } else {
      LoginScreen().launch(context);
      //launchNewScreen(context, LoginScreen.tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    //final appState = Provider.of<AppState>(context);

    void onTabTapped(int index) async {
      var pref = await getSharedPref();
      setState(() {
        if (index == 0) {
          appBarTitle = AppLocalizations.of(context).translate('home');
        } else if (index == 1) {
          if (pref.getBool(IS_LOGGED_IN) != null) {
          } else {
            LoginScreen().launch(context);
            //launchNewScreen(context, LoginScreen.tag);
            return;
          }
          appBarTitle = AppLocalizations.of(context).translate('wishlist');
        } else if (index == 2) {
          if (pref.getBool(IS_LOGGED_IN) != null) {
          } else {
            LoginScreen().launch(context);
            //launchNewScreen(context, LoginScreen.tag);
            return;
          }
          appBarTitle = AppLocalizations.of(context).translate('cart');
        } else if (index == 3) {
          if (pref.getBool(IS_LOGGED_IN) != null) {
          } else {
            LoginScreen().launch(context);
            //launchNewScreen(context, LoginScreen.tag);
            return;
          }
          appBarTitle = AppLocalizations.of(context).translate('profile');
        }
        mCurrentIndex = index;
      });
    }

    void onShareTap() async {
      final RenderBox box = context.findRenderObject();
      Share.share(shareMsg, subject: 'Share $mAppName App', sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }

    void onContactUsTap() async {
      redirectUrl(contactUsUrl);
    }

    Widget appBar = AppBar(
      actions: <Widget>[
        IconButton(icon: Icon(Icons.search, color: blackColor), onPressed: () => {SearchScreen().launch(context)})
      ],
      leading: Builder(builder: (context) => IconButton(icon: new Icon(Icons.menu, color: blackColor), onPressed: () => {Scaffold.of(context).openDrawer()})),
      backgroundColor: Colors.white,
      title: Text(appBarTitle, style: TextStyle(color: blackColor)),
    );

    Widget categoryListView = Container(
      child: ListView.builder(
        itemCount: mCategoryModel.length,
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 14, top: 8, bottom: 8, right: 8),
        physics: ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Scaffold.of(context).openEndDrawer();
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(mCategoryData: mCategoryModel[index])));
            },
            child: Container(padding: EdgeInsets.all(8), child: Text(mCategoryModel[index].name, style: drawerTextStyle)),
          );
        },
      ),
    );

    Widget drawer = Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            CloseButton().onTap(() => scaffoldKey.currentState.openEndDrawer()),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  if (mProfileImage != null) Image.network(mProfileImage, height: 100, width: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(200),
                  SizedBox(height: 10),
                  Text(userName, style: TextStyle(color: blackColor, fontSize: 20)),
                ],
              ),
            ).visible(userName.isNotEmpty),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => {scaffoldKey.currentState.openEndDrawer(), checkLoggedIn(context, MyOrdersScreen.tag)},
                    child: Column(
                      children: <Widget>[
                        Text(orderCount.toString(), style: TextStyle(color: primaryColor, fontSize: 20)),
                        Text(AppLocalizations.of(context).translate('my_orders'), style: drawerTextStyle)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {
                      scaffoldKey.currentState.openEndDrawer(),
                      setState(() {
                        mCurrentIndex = 1;
                      })
                    },
                    child: Column(
                      children: <Widget>[
                        Text(mWishListCount < 10 ? '0$mWishListCount' : mWishListCount.toString(), style: TextStyle(color: primaryColor, fontSize: 20)),
                        Text(AppLocalizations.of(context).translate('wishlist'), style: drawerTextStyle)
                      ],
                    ),
                  )
                ],
              ),
            ),
            categoryListView,
            SizedBox(height: 10),
            Divider(height: 1),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton.icon(
                  icon: Image.asset('assets/ic_offers.png', height: 24, width: 24),
                  label: Text(AppLocalizations.of(context).translate('special_offers'), style: drawerTextStyle),
                  onPressed: () => {scaffoldKey.currentState.openEndDrawer(), launchNewScreen(context, MyOffersScreen.tag)},
                ),
                FlatButton.icon(
                  icon: Image.asset('assets/ic_blog.png', height: 24, width: 24),
                  label: Text(AppLocalizations.of(context).translate('blogs'), style: drawerTextStyle),
                  onPressed: () => {scaffoldKey.currentState.openEndDrawer(), launchNewScreen(context, BlogScreen.tag)},
                ),
                FlatButton.icon(
                  icon: Image.asset('assets/ic_user.png', width: 24, height: 24),
                  label: Text(AppLocalizations.of(context).translate('account'), style: drawerTextStyle),
                  onPressed: () => {scaffoldKey.currentState.openEndDrawer(), checkLoggedIn(context, AccountScreen.tag)},
                ),
                FlatButton.icon(
                  icon: Image.asset('assets/ic_settings.png', height: 24, width: 24),
                  label: Text(AppLocalizations.of(context).translate('settings'), style: drawerTextStyle),
                  onPressed: () => {scaffoldKey.currentState.openEndDrawer(), launchNewScreen(context, SettingScreen.tag)},
                ),
                FlatButton.icon(
                  icon: Image.asset('assets/ic_logout.png', width: 24, height: 24),
                  label: Text(lblLogin, style: drawerTextStyle),
                  onPressed: () => {scaffoldKey.currentState.openEndDrawer(), checkLogin(context)},
                ),
              ],
            ).paddingLeft(8),
            SizedBox(height: 10),
            Divider(height: 1),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: GestureDetector(
                onTap: () => {scaffoldKey.currentState.openEndDrawer(), launchNewScreen(context, FAQScreen.tag)},
                child: Row(
                  children: <Widget>[Text(AppLocalizations.of(context).translate('faq'), style: drawerTextStyle)],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: GestureDetector(
                onTap: () => {scaffoldKey.currentState.openEndDrawer(), onContactUsTap()},
                child: Row(
                  children: <Widget>[Text(AppLocalizations.of(context).translate('contact_us'), style: drawerTextStyle)],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: GestureDetector(
                onTap: () => {scaffoldKey.currentState.openEndDrawer(), launchNewScreen(context, AboutScreen.tag)},
                child: Row(
                  children: <Widget>[Text(AppLocalizations.of(context).translate('about_us'), style: drawerTextStyle)],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: GestureDetector(
                onTap: () => {scaffoldKey.currentState.openEndDrawer(), onShareTap()},
                child: Row(
                  children: <Widget>[Text(AppLocalizations.of(context).translate('share_app'), style: drawerTextStyle)],
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      drawer: drawer,
      body: viewContainer[mCurrentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: mCurrentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: mCurrentIndex == 0 ? primaryColor : bottomNavIconColor),
            title: Text(AppLocalizations.of(context).translate('home'), style: TextStyle(color: mCurrentIndex == 0 ? primaryColor : Colors.black)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: mCurrentIndex == 1 ? primaryColor : bottomNavIconColor),
            title: Text(AppLocalizations.of(context).translate('wishlist'), style: TextStyle(color: mCurrentIndex == 1 ? primaryColor : Colors.black)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: mCurrentIndex == 2 ? primaryColor : bottomNavIconColor),
            title: Text(AppLocalizations.of(context).translate('cart'), style: TextStyle(color: mCurrentIndex == 2 ? primaryColor : Colors.black)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: mCurrentIndex == 3 ? primaryColor : bottomNavIconColor),
            title: Text(AppLocalizations.of(context).translate('profile'), style: TextStyle(color: mCurrentIndex == 3 ? primaryColor : Colors.black)),
          )
        ],
      ),
    );
  }
}
