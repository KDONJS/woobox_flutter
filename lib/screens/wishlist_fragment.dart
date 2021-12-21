import 'dart:async';
import 'dart:convert';

import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/app_state.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/model/WishListModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishListFragment extends StatefulWidget {
  @override
  WishListFragmentState createState() {
    return WishListFragmentState();
  }
}

class WishListFragmentState extends State<WishListFragment> with AfterLayoutMixin<WishListFragment> {
  var mWishListModel = List<WishListModel>();
  var mErrorMsg = '';
  bool mIsLoading = false;
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
  }

  setWishListCount(count) {
    Provider.of<AppState>(context, listen: false).changeWishListCount(count);
  }

  Future fetchData() async {
    pref = await getSharedPref();
    getWishList().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mWishListModel = list.map((model) => WishListModel.fromJson(model)).toList();
        mErrorMsg = '';
        pref.setString(WISHLIST_DATA, jsonEncode(res));
        //setWishListCount(mWishListModel.length);
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        mWishListModel.clear();
        mErrorMsg = error.toString();
      });
    });
  }

  handleProductClick(productId) async {
    setState(() {
      mIsLoading = true;
    });
    await getSingleProducts(productId).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetail(product: ProductModelNew.fromJson(res))));
      });
    }).catchError((error) {
      setState(() {
        mIsLoading = false;
      });
      toast(error.toString());
    });
  }

  Future addToCartApi(pro_id, value) async {
    var removeWishListRequest = {
      'pro_id': pro_id,
    };

    removeWishList(removeWishListRequest).then((res) {
      if (!mounted) return;
      var request = {
        'pro_id': pro_id,
        'quantity': value,
        'color': '',
        'size': '',
      };
      addToCart(request).then((res) {
        toast(res[msg]);
        fetchData();
      }).catchError((error) {
        toast(error.toString());
      });
    }).catchError((error) {});
  }

  Future removeWishListApi(pro_id) async {
    var removeWishListRequest = {
      'pro_id': pro_id,
    };

    removeWishList(removeWishListRequest).then((res) {
      if (!mounted) return;
      fetchData();
    }).catchError((error) {});
  }

  @override
  void afterFirstLayout(BuildContext context) {
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final listView = ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: mWishListModel.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => {handleProductClick(mWishListModel[index].pro_id)},
          child: Container(
            color: productContainerBgColor,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.network(mWishListModel[index].full, fit: BoxFit.cover, height: 180, width: 150),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        mWishListModel[index].name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      PriceWidget(price: mWishListModel[index].price.toString(), size: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(Icons.add_shopping_cart, color: Colors.black),
                            onPressed: () => addToCartApi(mWishListModel[index].pro_id, 1),
                            label: Text(AppLocalizations.of(context).translate('move_to_cart'), style: TextStyle(color: Colors.black)),
                          ),
                          FlatButton.icon(
                            icon: Icon(Icons.delete_outline, color: Colors.black),
                            onPressed: () => removeWishListApi(mWishListModel[index].pro_id),
                            label: Text(AppLocalizations.of(context).translate('remove'), style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    return Scaffold(
      body: mErrorMsg.isEmpty
          ? mWishListModel.isNotEmpty
              ? SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 16),
                      !mIsLoading ? listView : Stack(alignment: Alignment.center, children: <Widget>[listView, Center(child: CircularProgressIndicator())])
                    ],
                  ),
                )
              : Center(child: CircularProgressIndicator())
          : Center(child: Text(mErrorMsg)),
    );
  }
}
