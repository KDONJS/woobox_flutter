import 'dart:convert';

import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/CartModel.dart';
import 'package:WooBox/model/CategoryData.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/model/SliderModel.dart';
import 'package:WooBox/model/TestimonialsData.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/screens/view_all_product_screen.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeFragment extends StatefulWidget {
  @override
  HomeFragmentState createState() {
    return HomeFragmentState();
  }
}

class HomeFragmentState extends State<HomeFragment> /*with AfterLayoutMixin<HomeFragment>*/ {
  var mErrorMsg = '';
  var mIsLoggedIn = false;
  bool mIsLoading = true;

  var mSliderModel = List<SliderModel>();
  var mSliderImages = List<String>();
  var mCategoryModel = List<CategoryData>();

  var mNewestProductModel = List<ProductModelNew>();
  var mFeaturedProductModel = List<ProductModelNew>();
  var mYouMayLikeProductModel = List<ProductModelNew>();
  var mOfferProductModel = List<ProductModelNew>();
  var mDealProductModel = List<ProductModelNew>();
  var mSuggestedProductModel = List<ProductModelNew>();

  var mTestimonialsModel = List<TestimonialsData>();

  var mBanner1 = "";
  var mBanner2 = "";
  var mBanner3 = "";

  SharedPreferences pref;
  Color primaryColor;
  var mIsFirstTime = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /*@override
  void afterFirstLayout(BuildContext context) {
    //fetchData();
  }*/

  fetchData() async {
    pref = await getSharedPref();
    primaryColor = await getThemeColor();
    mIsLoggedIn = await isLoggedIn();
    if (pref.getString(DASHBOARD_DATA) != null) {
      setProductData(jsonDecode(pref.getString(DASHBOARD_DATA)));
    }
    if (pref.getString(SLIDER_DATA) != null) {
      Iterable list = jsonDecode(pref.getString(SLIDER_DATA));
      mSliderModel = list.map((model) => SliderModel.fromJson(model)).toList();

      mSliderModel.forEach((s) {
        mSliderImages.add(s.image);
      });
    }
    if (pref.getString(CATEGORY_DATA) != null) {
      Iterable list = jsonDecode(pref.getString(CATEGORY_DATA));
      mCategoryModel = list.map((model) => CategoryData.fromJson(model)).toList();
    }
    setState(() {});
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getDashboardApi().then((res) async {
          if (!mounted) return;
          mIsLoading = false;
          pref.setString(DASHBOARD_DATA, jsonEncode(res));
          pref.setString(DEFAULT_CURRENCY, parseHtmlString(res['currency_symbol']['currency_symbol']));

          if (res['theme_color'] != null && res['theme_color'].toString().isNotEmpty) {
            pref.setString(THEME_COLOR, res['theme_color']);
          } else {
            pref.remove(THEME_COLOR);
          }
          setProductData(res);

          if (res['total_order'] != null) {
            getSharedPref().then((pref) {
              pref.setInt(ORDER_COUNT, res['total_order']);
            });
          }
          if (res['social_link'] != null) {
            getSharedPref().then((pref) {
              pref.setString(WHATSAPP, res['social_link']['whatsapp']);
              pref.setString(FACEBOOK, res['social_link']['facebook']);
              pref.setString(TWITTER, res['social_link']['twitter']);
              pref.setString(INSTAGRAM, res['social_link']['instagram']);
              pref.setString(CONTACT, res['social_link']['contact']);
              pref.setString(PRIVACY_POLICY, res['social_link']['privacy_policy']);
              pref.setString(TERMS_AND_CONDITIONS, res['social_link']['term_condition']);
              pref.setString(COPYRIGHT_TEXT, res['social_link']['copyright_text']);
            });
          }

          if (res['banner_1']['image'] != null) {
            mBanner1 = res['banner_1']['image'];
          }
          if (res['banner_2']['image'] != null) {
            mBanner2 = res['banner_2']['image'];
          }
          if (res['banner_3'] != null) {
            mBanner3 = res['banner_3']['image'];
          }
          mErrorMsg = '';
          await getCategories().then((res) {
            if (!mounted) return;
            Iterable list = res;
            mCategoryModel = list.map((model) => CategoryData.fromJson(model)).toList();
          }).catchError((error) {
            print(error);
            if (!mounted) return;
          });
          mSliderImages.clear();
          await getSliderImages().then((res) {
            if (!mounted) return;
            Iterable list = res;
            mSliderModel = list.map((model) => SliderModel.fromJson(model)).toList();

            mSliderModel.forEach((s) {
              if (s.image.isNotEmpty) mSliderImages.add(s.image);
            });
            pref.setString(SLIDER_DATA, jsonEncode(res));
          }).catchError((error) {});
        }).catchError((error) {
          if (!mounted) return;
          mIsLoading = false;
          mErrorMsg = errorMsg;
        });
        if (mIsLoggedIn) {
          await getCartList().then((res) {
            Iterable list = res;
            var mCartModel = list.map((model) => CartModel.fromJson(model)).toList();
            setCartCount(mCartModel.length);
          }).catchError((error) {
            if (!mounted) return;
          });
        }
        if (!mounted) return;
      } else {
        toast(noInternetMsg);
        if (!mounted) return;
        mIsLoading = false;
      }
      setState(() {});
    });
  }

  void setProductData(res) {
    Iterable youMayLike = res['you_may_like'];
    mYouMayLikeProductModel = youMayLike.map((model) => ProductModelNew.fromJson(model)).toList();

    Iterable offer = res['offer'];
    mOfferProductModel = offer.map((model) => ProductModelNew.fromJson(model)).toList();

    Iterable newest = res['newest'];
    mNewestProductModel = newest.map((model) => ProductModelNew.fromJson(model)).toList();

    Iterable deal = res['deal_product'];
    mDealProductModel = deal.map((model) => ProductModelNew.fromJson(model)).toList();

    Iterable suggested = res['suggested_product'];
    mSuggestedProductModel = suggested.map((model) => ProductModelNew.fromJson(model)).toList();

    Iterable featured = res['featured'];
    mFeaturedProductModel = featured.map((model) => ProductModelNew.fromJson(model)).toList();

    Iterable testimonials = res['testimonials'];
    if (testimonials != null) mTestimonialsModel = testimonials.map((model) => TestimonialsData.fromJson(model)).toList();
  }

  void onProductTap(product) async {
    Navigator.push(context, MaterialPageRoute(maintainState: true, builder: (context) => ProductDetail(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    //final appState = Provider.of<AppState>(context);
    //appState.setOrderCount(pref.getInt(ORDER_COUNT));

    List<T> map<T>(List list, Function handler) {
      List<T> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i, list[i]));
      }
      return result;
    }

    Widget carousel = Carousel(
      images: map<Widget>(
        mSliderImages,
        (index, i) {
          return InkWell(
            onTap: () => redirectUrl(mSliderModel[index].url),
            child: Image.network(i, fit: BoxFit.cover, width: double.infinity),
          );
        },
      ).toList(),
      indicatorBgPadding: 5,
      autoplay: false,
    ).withSize(height: 200, width: MediaQuery.of(context).size.width - 32).cornerRadiusWithClipRRect(8).center();

    Widget categoryListView = Container(
      height: productCategoryHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(8),
        itemCount: mCategoryModel.length,
        itemBuilder: (context, index) {
          return getCategoryWidget(context, mCategoryModel[index], index);
        },
      ),
    );

    Widget newestProductLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('newest_products'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => launchNewScreen(context, ViewAllProductScreen.tag),
            child: Text(AppLocalizations.of(context).translate('view_all'), style: TextStyle(color: primaryColor, fontSize: 16)),
          )
        ],
      ),
    );

    Widget newestProductListView = Container(
      height: productContainerHeight,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(8),
          itemCount: mNewestProductModel.length >= 5 ? 5 : mNewestProductModel.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onProductTap(mNewestProductModel[index]),
              child: getProductWidget(mNewestProductModel[index]),
            );
          }),
    );

    Widget featuredProductLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('featured_products'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => launchNewScreen(context, ViewAllProductScreen.tag),
            child: Text(AppLocalizations.of(context).translate('view_all'), style: TextStyle(color: primaryColor, fontSize: 16)),
          )
        ],
      ),
    );

    Widget featuredProductListView = Container(
      height: productContainerHeight,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(8),
          itemCount: mFeaturedProductModel.length >= 5 ? 5 : mFeaturedProductModel.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onProductTap(mFeaturedProductModel[index]),
              child: getProductWidget(mFeaturedProductModel[index]),
            );
          }),
    );

    Widget testimonialsLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(AppLocalizations.of(context).translate('testimonials'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
    );

    Widget testimonialsWidget = Swiper(
      itemWidth: 350.0,
      containerHeight: 300.0,
      itemHeight: 300.0,
      itemCount: mTestimonialsModel.length,
      layout: SwiperLayout.STACK,
      itemBuilder: (_, pos) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 4,
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  mTestimonialsModel[pos].image != null ? Image.network(mTestimonialsModel[pos].image, height: 50, width: 50) : SizedBox(height: 50),
                  if (mTestimonialsModel[pos].name != null) Text(mTestimonialsModel[pos].name, style: boldFonts(color: primaryColor)),
                  if (mTestimonialsModel[pos].company != null) Text(mTestimonialsModel[pos].company),
                  if (mTestimonialsModel[pos].designation != null) Text(mTestimonialsModel[pos].designation),
                  SizedBox(height: 10),
                  Flexible(child: Text('"${mTestimonialsModel[pos].message.validate()}"', style: TextStyle(fontSize: 18), textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.clip)),
                ],
              ),
            ),
          ),
        );
      },
    );

    Widget dealProductLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('deal'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => launchNewScreen(context, ViewAllProductScreen.tag),
            child: Text(AppLocalizations.of(context).translate('view_all'), style: TextStyle(color: primaryColor, fontSize: 16)),
          )
        ],
      ),
    );

    Widget dealProductListView = Container(
      height: productContainerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(8),
        itemCount: mDealProductModel.length >= 5 ? 5 : mDealProductModel.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onProductTap(mDealProductModel[index]),
            child: getProductWidget(mDealProductModel[index]),
          );
        },
      ),
    );

    Widget suggestedProductLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('suggested'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => ViewAllProductScreen().launch(context),
            child: Text(AppLocalizations.of(context).translate('view_all'), style: TextStyle(color: primaryColor, fontSize: 16)),
          )
        ],
      ),
    );

    Widget suggestedProductListView = Container(
      height: productContainerHeight,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(8),
          itemCount: mSuggestedProductModel.length >= 5 ? 5 : mSuggestedProductModel.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onProductTap(mSuggestedProductModel[index]),
              child: getProductWidget(mSuggestedProductModel[index]),
            );
          }),
    );

    Widget offerProductLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('offers'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => ViewAllProductScreen().launch(context),
            child: Text(AppLocalizations.of(context).translate('view_all'), style: TextStyle(color: primaryColor, fontSize: 16)),
          )
        ],
      ),
    );

    Widget offerProductListView = Container(
      height: productContainerHeight,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mOfferProductModel.length >= 5 ? 5 : mOfferProductModel.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onProductTap(mOfferProductModel[index]),
              child: getProductWidget(mOfferProductModel[index]),
            );
          }),
    );

    Widget youMayLikeProductLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('you_may_like'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () {
              ViewAllProductScreen().launch(context);
            },
            child: Text(AppLocalizations.of(context).translate('view_all'), style: TextStyle(color: primaryColor, fontSize: 16)),
          )
        ],
      ),
    );

    Widget youMayLikeProductListView = Container(
      height: productContainerHeight,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mYouMayLikeProductModel.length >= 5 ? 5 : mYouMayLikeProductModel.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onProductTap(mYouMayLikeProductModel[index]),
              child: getProductWidget(mYouMayLikeProductModel[index]),
            );
          }),
    );

    Widget banner1 = InkWell(
      onTap: () {
        redirectUrl(mBanner1);
      },
      child: Container(
        height: 200,
        margin: EdgeInsets.all(16),
        width: double.infinity,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          border: Border.all(color: viewLineColor),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          image: DecorationImage(image: NetworkImage(mBanner1), fit: BoxFit.cover),
        ),
      ),
    );

    Widget banner2 = InkWell(
      onTap: () {
        redirectUrl(mBanner2);
      },
      child: Container(
        height: 200,
        margin: EdgeInsets.all(16),
        width: double.infinity,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          border: Border.all(color: viewLineColor),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          image: DecorationImage(image: NetworkImage(mBanner2), fit: BoxFit.cover),
        ),
      ),
    );

    Widget banner3 = InkWell(
      onTap: () {
        redirectUrl(mBanner3);
      },
      child: Container(
        height: 200,
        margin: EdgeInsets.all(16),
        width: double.infinity,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          border: Border.all(color: viewLineColor),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          image: DecorationImage(image: NetworkImage(mBanner3), fit: BoxFit.cover),
        ),
      ),
    );

    Widget body = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          16.height,
          carousel.visible(mSliderImages.isNotEmpty),
          SizedBox(height: 10),
          categoryListView.visible(mCategoryModel.isNotEmpty),
          SizedBox(height: 10).visible(mCategoryModel.isNotEmpty),
          newestProductLabel.visible(mNewestProductModel.isNotEmpty),
          newestProductListView.visible(mNewestProductModel.isNotEmpty),
          featuredProductLabel.visible(mFeaturedProductModel.isNotEmpty),
          featuredProductListView.visible(mFeaturedProductModel.isNotEmpty),
          SizedBox(height: 10),
          testimonialsLabel.visible(mTestimonialsModel.isNotEmpty),
          SizedBox(height: 10),
          testimonialsWidget.visible(mTestimonialsModel.isNotEmpty),
          SizedBox(height: 10),
          banner1.visible(mBanner1.isNotEmpty),
          SizedBox(height: 10),
          dealProductLabel.visible(mDealProductModel.isNotEmpty),
          dealProductListView.visible(mDealProductModel.isNotEmpty),
          SizedBox(height: 10),
          suggestedProductLabel.visible(mSuggestedProductModel.isNotEmpty),
          suggestedProductListView.visible(mSuggestedProductModel.isNotEmpty),
          SizedBox(height: 10),
          banner2.visible(mBanner2.isNotEmpty),
          SizedBox(height: 10),
          offerProductLabel.visible(mOfferProductModel.isNotEmpty),
          offerProductListView.visible(mOfferProductModel.isNotEmpty),
          SizedBox(height: 10),
          youMayLikeProductLabel.visible(mYouMayLikeProductModel.isNotEmpty),
          youMayLikeProductListView.visible(mYouMayLikeProductModel.isNotEmpty),
          banner3.visible(mBanner3.isNotEmpty),
          SizedBox(height: 10),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          body,
          CircularProgressIndicator().center().visible(mIsLoading),
        ],
      ),
    );
  }
}
