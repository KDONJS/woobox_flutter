import 'package:WooBox/model/CategoryData.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/category_detail_screen.dart';
import 'package:WooBox/screens/login_screen.dart';
import 'package:WooBox/service/LoginService.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_widgets.dart';
import 'colors.dart';
import 'constants.dart';

String regularFonts() {
  return GoogleFonts.montserrat().fontFamily;
}

TextStyle boldFonts({color = blackColor, size = 16.0}) {
  return GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: size is int ? double.parse(size.toString()).toDouble() : size, textStyle: TextStyle(color: color));
}

setCartCount(count) async {
  await getSharedPref().then((pref) {
    pref.setInt(CART_COUNT, count);
  });
}

Future<String> getDefaultCurrency() async {
  await getSharedPref().then((pref) {
    print(pref.getString(DEFAULT_CURRENCY));
    if (pref.get(DEFAULT_CURRENCY) != null) {
      return pref.getString(DEFAULT_CURRENCY);
    } else
      return '';
  });
  return '';
}

String convertDate(date) {
  try {
    return date != null ? DateFormat(dateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    print(e);
    return '';
  }
}

Widget getAppBar(context, String title, {color = whiteColor, textColor: blackColor}) {
  return AppBar(
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: textColor),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(title, style: TextStyle(color: textColor)),
    backgroundColor: color,
  );
}

Widget getPrimaryButton(String text) {
  return MaterialButton(
    height: materialButtonHeight,
    minWidth: double.infinity,
    onPressed: () => {},
    shape: roundedRectangleBorder(20),
    color: primaryColor,
    child: Text(text),
    textColor: Colors.white,
  );
}

Widget getSecondaryButton(String text) {
  return MaterialButton(
    height: materialButtonHeight,
    minWidth: double.infinity,
    onPressed: () => {},
    shape: roundedRectangleBorder(20),
    color: Colors.white,
    child: Text(text),
    textColor: primaryColor,
  );
}

void redirectUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    toast('Please check URL');
    throw 'Could not launch $url';
  }
}

Future openRateProductDialog(context, onSubmit) async {
  var reviewCont = TextEditingController();
  var ratings = 0.0;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Text('Rate this product', style: boldFonts()),
                  SizedBox(height: 20),
                  RatingBar(
                    initialRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      ratings = rating;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: reviewCont,
                    maxLines: 5,
                    minLines: 2,
                    decoration: InputDecoration(hintText: 'Review'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          elevation: 10,
                          color: primaryColor,
                          onPressed: () {
                            if (ratings < 1) {
                              toast('Please Rate');
                            } else if (reviewCont.text.isEmpty) {
                              toast('Please Review');
                            } else {
                              onSubmit(reviewCont.text, ratings);
                            }
                          },
                          child: Text('Rate Now', style: TextStyle(color: whiteColor)),
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
    },
  );
}

addList(list) {
  list.add("Address Manager");
  list.add("My Orders");
  //list.add("Special Offers");
  //list.add("Help Center");
}

Future logout() async {
  await LoginService().signOut().catchError((error) {});
  var pref = await getSharedPref();
  var primaryColor = pref.getString(THEME_COLOR);
  if (pref.getBool(IS_LOGGED_IN) != null) {
    pref.clear();
  }
  pref.remove(PROFILE_IMAGE);
  pref.setString(THEME_COLOR, primaryColor);
}

Widget getProductWidget(ProductModelNew product, {double width = 180}) {
  return Container(
    width: width,
    height: productContainerHeight,
    margin: EdgeInsets.all(8),
    child: Stack(
      children: [
        product.full != null ? Image.network(product.full.validate(), height: productContainerHeight, width: width, fit: BoxFit.cover) : Container(height: productContainerHeight),
        Positioned(
          right: 0,
          child: Container(
            color: Colors.green.withOpacity(0.1),
            padding: EdgeInsets.all(6),
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                double.parse(product.average_rating.validate(value: '0.0')).toInt().toString().text(style: boldTextStyle(color: Colors.green, size: 13)),
                2.width,
                Icon(Icons.star_border, size: 13, color: Colors.green),
              ],
            ),
          ).cornerRadiusWithClipRRectOnly(topLeft: 0, bottomLeft: 4),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [transparentColor, const Color(0x8C001510).withOpacity(0.6)],
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                tileMode: TileMode.mirror,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                product.name.validate().text(maxLines: 1, overflow: TextOverflow.ellipsis, style: boldFonts(color: whiteColor)),
                Row(
                  children: <Widget>[
                    PriceWidget(price: product.sale_price.validate().isNotEmpty ? product.sale_price.toString() : product.price.validate(), size: 18, color: whiteColor),
                    10.width,
                    PriceWidget(price: product.regular_price.validate().toString(), size: 14, isLineThroughEnabled: true, color: whiteColor).visible(product.sale_price.validate().isNotEmpty)
                  ],
                ),
              ],
            ).paddingAll(8),
          ),
        ),
      ],
    ).cornerRadiusWithClipRRect(4),
  );
}

Widget getCategoryWidget(context, CategoryData data, index) {
  return Container(
    padding: EdgeInsets.only(left: 8, right: 8),
    margin: EdgeInsets.all(4),
    alignment: Alignment.center,
    decoration: boxDecorationWithRoundedCorners(
      border: Border.all(color: transparentColor),
      backgroundColor: getColorFromHex(categoryColors[index % categoryColors.length]).withOpacity(0.1),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailScreen(mCategoryData: data)));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /*Container(
            height: 40,
            padding: EdgeInsets.all(10),
            child: data.image != null ? Image.network(data.image.validate(), height: 20, color: whiteColor) : SizedBox(height: 40),
            decoration: BoxDecoration(shape: BoxShape.circle, color: getColorFromHex(categoryColors[index % categoryColors.length])),
          ),*/
          Text(data.name.validate(), style: primaryTextStyle(color: getColorFromHex(categoryColors[index % categoryColors.length]))),
        ],
      ),
    ),
  );
}

Future openChangePasswordDialog(context) async {
  var oldPass = '';
  var newPass = '';
  var confirmPass = '';

  GlobalKey<FormState> key = new GlobalKey();
  var primaryColor = await getThemeColor();

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Form(
              key: key,
              autovalidate: false,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Text('Change Password', style: boldFonts(color: primaryColor, size: 18)),
                    SizedBox(height: 10),
                    TextFormField(
                      maxLines: 1,
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Old Password'),
                      validator: (String arg) {
                        if (arg.length < 1)
                          return 'Required';
                        else
                          return null;
                      },
                      onSaved: (val) {
                        oldPass = val;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(hintText: 'New Password'),
                      validator: (String arg) {
                        if (arg.length < 1)
                          return 'Required';
                        else
                          return null;
                      },
                      onSaved: (val) {
                        newPass = val;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      maxLines: 1,
                      obscureText: true,
                      decoration: InputDecoration(hintText: 'Password Again'),
                      validator: (String arg) {
                        if (arg.length < 1)
                          return 'Required';
                        else
                          confirmPass = arg;
                        return null;
                      },
                      onSaved: (val) {
                        confirmPass = val;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: MaterialButton(
                            elevation: 10,
                            color: primaryColor,
                            onPressed: () {
                              if (key.currentState.validate()) {
                                var request = {'password': confirmPass};

                                changePassword(request).then((res) {
                                  finish(context);
                                }).catchError((error) {
                                  toast(error.toString());
                                });
                              }
                            },
                            child: Text('Save', style: TextStyle(color: whiteColor)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

String parseHtmlString(String htmlString) {
  return parse(parse(htmlString).body.text).documentElement.text;
}

Future<bool> checkLogin(context) async {
  if (!await isLoggedIn()) {
    LoginScreen().launch(context);
    return false;
  } else {
    return true;
  }
}
