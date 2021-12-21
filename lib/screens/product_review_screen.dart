import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/ProductReviewModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductReviewScreen extends StatefulWidget {
  static String tag = '/ProductReviewScreen';
  final mProductId;

  ProductReviewScreen({Key key, this.mProductId}) : super(key: key);

  @override
  ProductReviewScreenState createState() {
    return ProductReviewScreenState();
  }
}

class ProductReviewScreenState extends State<ProductReviewScreen> {
  var mReviewModel = List<ProductReviewModel>();
  var mErrorMsg = '';
  var mUserEmail = '';

  var fiveStars = 0;
  var fourStars = 0;
  var threeStars = 0;
  var twoStars = 0;
  var oneStars = 0;
  double avgRating = 0.0;

  var fiveStarPercent = 0.0;
  var fourPercent = 0.0;
  var threePercent = 0.0;
  var twoPercent = 0.0;
  var onePercent = 0.0;

  var primaryColor;
  SharedPreferences pref;
  bool mIsLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    getPrefs();
  }

  void getPrefs() async {
    pref = await getSharedPref();
    mIsLoggedIn = await isLoggedIn();
    primaryColor = await getThemeColor();
    setState(() {});
    if (await getBool(IS_LOGGED_IN)) {
      mUserEmail = await getString(USER_EMAIL);
    }
  }

  Future fetchData() async {
    await getProductReviews(widget.mProductId).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mReviewModel = list.map((model) => ProductReviewModel.fromJson(model)).toList();
        if (mReviewModel.isEmpty) {
          mErrorMsg = AppLocalizations.of(context).translate('no_reviews');
          fiveStars = 0;
          fourStars = 0;
          threeStars = 0;
          twoStars = 0;
          oneStars = 0;
          avgRating = 0.0;
          fiveStarPercent = 0.0;
          fourPercent = 0.0;
          threePercent = 0.0;
          twoPercent = 0.0;
          onePercent = 0.0;
        } else {
          mErrorMsg = '';
          setReviews();
        }
      });
    }).catchError((error) {
      setState(() {
        mErrorMsg = error;
      });
    });
  }

  Future postReviewApi(product_id, review, rating) async {
    var request = {'product_id': product_id, 'reviewer': pref.getString(USERNAME), 'reviewer_email': pref.getString(USER_EMAIL), 'review': review, 'rating': rating};
    postReview(request).then((res) {
      if (!mounted) return;
      finish(context); // Dismiss Dialog
      setState(() {
        mReviewModel.clear(); // To be cleared to show Progress Bar
      });
      fetchData();
    }).catchError((error) {
      toast(error);
    });
  }

  Function onPositiveClick(request) {
    /*deleteReview(request).then((res) {
      toast(res[msg]);
      fetchData();
    }).catchError((error) {
      toast(error);
    });*/
  }

  Future deleteReviewApi(review_id) async {
    if (!accessAllowed) {
      toast(demoPurposeMsg);
      return;
    }
    var request = {
      'review_id': review_id,
    };
    deleteReview(request).then((res) {
      if (!mounted) return;
      toast(res[msg]);
      fetchData();
    }).catchError((error) {
      toast(error);
    });
    /*BuildAlertDialog(
        'Are you sure want to delete review?', onPositiveClick(request));*/
    /*alertDialog(context, 'Are you sure want to delete review?',
        onPositiveClick(request));*/
  }

  Future setReviews() async {
    if (mReviewModel.isEmpty) return;

    var fiveStar = 0;
    var fourStar = 0;
    var threeStar = 0;
    var twoStar = 0;
    var oneStar = 0;

    var totalRatings = 0;

    mReviewModel.forEach((item) {
      if (item.rating == 1) {
        oneStar++;
      } else if (item.rating == 2) {
        twoStar++;
      } else if (item.rating == 3) {
        threeStar++;
      } else if (item.rating == 4) {
        fourStar++;
      } else if (item.rating == 5) {
        fiveStar++;
      }
    });
    if (fiveStar == 0 && fourStar == 0 && threeStar == 0 && twoStar == 0 && oneStar == 0) {
      return;
    }
    setState(() {
      fiveStars = fiveStar;
      fourStars = fourStar;
      threeStars = threeStar;
      twoStars = twoStar;
      oneStars = oneStar;

      totalRatings = fiveStar + fourStar + threeStar + twoStar + oneStar;

      var mAvgRating = (5 * fiveStar + 4 * fourStar + 3 * threeStar + 2 * twoStar + 1 * oneStar) / (totalRatings);
      avgRating = double.parse(mAvgRating.toStringAsPrecision(2)).toDouble();

      fiveStarPercent = calculateRatings(totalRatings, fiveStar);
      fourPercent = calculateRatings(totalRatings, fourStar);
      threePercent = calculateRatings(totalRatings, threeStar);
      twoPercent = calculateRatings(totalRatings, twoStar);
      onePercent = calculateRatings(totalRatings, oneStar);
    });
  }

  double calculateRatings(total, starCount) {
    if (starCount < 1) return 0.0;
    var a = total / starCount;
    var b = a * 10;
    var c = b / 100;
    var d = 1.0 - c;
    return d;
  }

  @override
  Widget build(BuildContext context) {
    void onSubmit(review, rating) async {
      if (accessAllowed) {
        postReviewApi(widget.mProductId, review, rating);
      } else {
        toast(demoPurposeMsg);
      }
    }

    Widget body = Container(
      padding: EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('ratings'), style: TextStyle(fontWeight: FontWeight.bold)),
            MaterialButton(
              shape: roundedRectangleBorder(20, color: primaryColor),
              child: Text(AppLocalizations.of(context).translate('rate_now'), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await checkLogin(context).then((value) {
                  if (value) openRateProductDialog(context, onSubmit);
                });
              },
            )
          ],
        ),
        SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: viewLineColor),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text(avgRating.toString(), style: boldFonts(color: primaryColor, size: 20)), Icon(Icons.star_border, color: primaryColor, size: 22)]),
                  Text(AppLocalizations.of(context).translate('avg_ratings'), style: boldFonts(color: textSecondaryColor, size: 14))
                ],
              ),
            ),
          ),
          SizedBox(width: 30),
          Column(children: <Widget>[
            SizedBox(height: 10),
            Text('1'),
            SizedBox(height: 4),
            Text('2'),
            SizedBox(height: 4),
            Text('3'),
            SizedBox(height: 4),
            Text('4'),
            SizedBox(height: 4),
            Text('5'),
          ]),
          SizedBox(width: 10),
          Column(
            children: <Widget>[
              SizedBox(height: 10),
              SizedBox(height: 5),
              LinearPercentIndicator(
                width: 150.0,
                animateFromLastPercent: true,
                lineHeight: 8.0,
                animation: true,
                percent: onePercent,
                backgroundColor: viewLineColor,
                progressColor: Colors.green,
              ),
              SizedBox(height: 12),
              LinearPercentIndicator(
                width: 150.0,
                lineHeight: 8.0,
                animation: true,
                percent: twoPercent,
                animateFromLastPercent: true,
                backgroundColor: viewLineColor,
                progressColor: Colors.lightGreenAccent,
              ),
              SizedBox(height: 12),
              LinearPercentIndicator(
                width: 150.0,
                lineHeight: 8.0,
                animation: true,
                animateFromLastPercent: true,
                backgroundColor: viewLineColor,
                percent: threePercent,
                progressColor: Colors.yellow,
              ),
              SizedBox(height: 12),
              LinearPercentIndicator(
                backgroundColor: viewLineColor,
                width: 150.0,
                animation: true,
                animateFromLastPercent: true,
                lineHeight: 8.0,
                percent: fourPercent,
                progressColor: Colors.yellowAccent,
              ),
              SizedBox(height: 12),
              LinearPercentIndicator(
                backgroundColor: viewLineColor,
                width: 150.0,
                animateFromLastPercent: true,
                animation: true,
                lineHeight: 8.0,
                percent: fiveStarPercent,
                progressColor: Colors.red,
              ),
            ],
          ),
          SizedBox(width: 10),
          Column(children: <Widget>[
            SizedBox(height: 10),
            Text(oneStars.toString()),
            SizedBox(height: 4),
            Text(twoStars.toString()),
            SizedBox(height: 4),
            Text(threeStars.toString()),
            SizedBox(height: 4),
            Text(fourStars.toString()),
            SizedBox(height: 4),
            Text(fiveStars.toString()),
          ])
        ]),
        SizedBox(height: 20),
        Divider(height: 1),
        SizedBox(height: 10),
        Text(AppLocalizations.of(context).translate('reviews'), style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10)
      ]),
    );

    Widget listView = ListView.separated(
        separatorBuilder: (context, index) {
          return Divider();
        },
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        reverse: true,
        itemCount: mReviewModel.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 5),
                    SizedBox(
                        height: 20,
                        width: 55,
                        child: Container(
                          padding: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(8))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                mReviewModel[index].rating.toString(),
                                style: TextStyle(color: whiteColor),
                              ),
                              Icon(Icons.star_border, size: 16, color: whiteColor)
                            ],
                          ),
                        )),
                    mUserEmail == mReviewModel[index].email
                        ? IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () {
                              deleteReviewApi(mReviewModel[index].id);
                            })
                        : Container(),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(mReviewModel[index].review, style: TextStyle(color: textPrimaryColor, fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(convertDate(mReviewModel[index].date_created), style: TextStyle(color: textSecondaryColor, fontSize: 14)),
                    SizedBox(height: 2),
                    Text(mReviewModel[index].name, style: TextStyle(color: textSecondaryColor, fontSize: 14)),
                  ],
                )
              ],
            ),
          );
        });

    return Scaffold(
        appBar: getAppBar(context, AppLocalizations.of(context).translate('reviews')),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              body,
              mErrorMsg.isEmpty
                  ? mReviewModel.isNotEmpty
                      ? SingleChildScrollView(physics: BouncingScrollPhysics(), child: listView)
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(mErrorMsg),
                      ),
                    )
            ],
          ),
        ));
  }
}
