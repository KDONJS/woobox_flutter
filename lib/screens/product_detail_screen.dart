import 'dart:convert';

import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/ColorSizeSelectionModel.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/cart_screen.dart';
import 'package:WooBox/screens/product_review_screen.dart';
import 'package:WooBox/utils/PrefDB.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:badges/badges.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import 'login_screen.dart';

class ProductDetail extends StatefulWidget {
  static String tag = '/ProductDetail';
  final ProductModelNew product;

  ProductDetail({Key key, this.product}) : super(key: key);

  @override
  ProductDetailState createState() {
    return ProductDetailState();
  }
}

class ProductDetailState extends State<ProductDetail> with WidgetsBindingObserver {
  bool mIsInWishList = false;
  var mCartCount = 0;
  var discount = 0;
  var mColorList = List<ColorSizeSelectionModel>();
  var mSizeList = List<ColorSizeSelectionModel>();
  Color primaryColor;
  var mSelectedQty = '1';

  @override
  void initState() {
    super.initState();
    getCartCount();
    WidgetsBinding.instance.addObserver(this);
    if (widget.product.gallery == null) {
      widget.product.gallery = List();
    }
    if (widget.product.sale_price != null && widget.product.sale_price.isNotEmpty) {
      setState(() {
        double mrp = double.parse(widget.product.regular_price).toDouble();
        double discountPrice = double.parse(widget.product.price).toDouble();
        discount = (((mrp - discountPrice) / mrp) * 100).toInt();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getCartCount();
    }
  }

  getCartCount() async {
    primaryColor = await getThemeColor();
    setState(() {});

    await getSharedPref().then((pref) {
      if (pref.get(CART_COUNT) != null) {
        setState(() {
          mCartCount = pref.getInt(CART_COUNT);
        });
      }

      if (pref.getString(WISHLIST_DATA) != null) {
        checkExitsInWishList(jsonDecode(pref.getString(WISHLIST_DATA)));
      }
    });
  }

  checkExitsInWishList(res) async {
    await getWishListFromPref(res).then((res) {
      res.forEach((item) {
        if (item.pro_id == widget.product.pro_id) {
          setState(() {
            mIsInWishList = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mColorList.clear();
    mSizeList.clear();
    if (widget.product != null) {
      var colors = widget.product.color.split(','.trim()).map((s) => s).toList();
      colors.forEach((name) {
        if (name.isNotEmpty) {
          var item = ColorSizeSelectionModel();
          item.name = name.trim();
          item.isSelected = false;
          mColorList.add(item);
        }
      });

      var sizes = widget.product.size.split(','.trim()).map((s) => s).toList();
      sizes.forEach((name) {
        if (name.isNotEmpty) {
          var item = ColorSizeSelectionModel();
          item.name = name.trim();
          item.isSelected = false;
          mSizeList.add(item);
        }
      });
    }

    Future addToCartApi(pro_id, quantity, {returnExpected = false}) async {
      if (!await isLoggedIn()) {
        LoginScreen().launch(context);
        return;
      }
      if (widget.product.manage_stock) {
        if (widget.product.stock_quantity == null) {
          toast('Out Of Stock');
          return;
        }
      }
      var colorSelected = '';
      var sizeSelected = '';

      mColorList.forEach((item) {
        if (item.isSelected) {
          colorSelected = item.name;
        }
      });
      mSizeList.forEach((item) {
        if (item.isSelected) {
          sizeSelected = item.name;
        }
      });
      if (mColorList.isNotEmpty) {
        if (colorSelected.isEmpty) {
          toast(AppLocalizations.of(context).translate('please_select_color'));
        }
      }
      if (mSizeList.isNotEmpty) {
        if (sizeSelected.isEmpty) {
          toast(AppLocalizations.of(context).translate('please_select_size'));
        }
      }

      var request = {
        'pro_id': pro_id,
        'quantity': quantity,
        'color': colorSelected,
        'size': sizeSelected,
      };

      await addToCart(request).then((res) {
        toast(res[msg]);
        setState(() {
          mCartCount++;
        });
        return returnExpected;
      }).catchError((error) {
        toast(error.toString());
        return returnExpected;
      });
    }

    void onWishListTap() async {
      if (!mIsInWishList) {
        if (!await isLoggedIn()) {
          LoginScreen().launch(context);
          return;
        }

        setState(() {
          mIsInWishList = true;
        });
        var request = {'pro_id': widget.product.pro_id};
        await addWishList(request).then((res) {
          if (!mounted) return;
          setState(() {
            toast(res[msg]);
            if (res['data']['status'] != 200) {
              mIsInWishList = false;
            } else {
              mIsInWishList = true;
            }
          });
        }).catchError((error) {
          setState(() {
            toast(error.toString());
            mIsInWishList = false;
          });
        });
      } else {
        setState(() {
          mIsInWishList = false;
        });
        await removeWishList({
          'pro_id': widget.product.pro_id,
        }).then((res) {
          if (!mounted) return;
          setState(() {
            toast(res[msg]);
            mIsInWishList = false;
          });
        }).catchError((error) {
          setState(() {
            toast(error.toString());
            mIsInWishList = false;
          });
        });
      }
    }

    final body = Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(widget.product.name, style: TextStyle(fontSize: 26)),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          decoration: boxDecoration(radius: 0, bgColor: Colors.redAccent, color: Colors.redAccent),
                          child: Text('$discount% ${AppLocalizations.of(context).translate('off')}', style: boldFonts(color: whiteColor, size: 12)),
                        ).visible(discount != 0)
                      ],
                    ),
                    SizedBox(height: 10),
                    Stack(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            PriceWidget(
                                price: widget.product.sale_price.validate(value: "0").isNotEmpty ? widget.product.sale_price.validate(value: "0") : widget.product.price.validate(value: "0"),
                                size: 24),
                            SizedBox(width: 5),
                            PriceWidget(price: widget.product.regular_price.validate(value: "0"), size: 20, isLineThroughEnabled: true).visible(discount != 0),
                          ],
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () {
                              ProductReviewScreen(mProductId: widget.product.pro_id).launch(context);
                            },
                            child: ratingBarWidget(double.parse(widget.product.average_rating), itemSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(children: <Widget>[
                      Text('Availability: ', style: TextStyle(fontSize: 18)),
                      Text(
                        widget.product.stock_quantity == null ? 'Out Of Stock' : 'In Stock',
                        style: boldFonts(color: widget.product.stock_quantity != null ? primaryColor : Colors.redAccent, size: 18),
                      ),
                    ]),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlineButton(
                            onPressed: () {
                              addToCartApi(widget.product.pro_id, mSelectedQty);
                            },
                            color: primaryColor,
                            child: Text(
                              AppLocalizations.of(context).translate('add_to_cart'),
                              style: TextStyle(color: primaryColor, fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          value: mSelectedQty,
                          onChanged: (newValue) {
                            if (widget.product.stock_quantity == null) {
                              return;
                            }
                            if (int.parse(newValue) > widget.product.stock_quantity) {
                              toast('Quantity should be less than ${widget.product.stock_quantity}');
                            } else {
                              setState(() {
                                mSelectedQty = newValue.toString();
                              });
                            }
                          },
                          items: ['1', '2', '3', '4', '5'].map((item) {
                            return DropdownMenuItem(
                              child: Text(item.toString(), style: TextStyle(color: textPrimaryColor)),
                              value: item.toString(),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(widget.product.description, style: TextStyle(fontSize: 18), textAlign: TextAlign.justify),
                    if (mColorList.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          Text(AppLocalizations.of(context).translate('colors'), style: boldFonts(size: 18)),
                          SizedBox(height: 20),
                          ColorListView(list: mColorList),
                          SizedBox(height: 10),
                        ],
                      ),
                    if (mSizeList.isNotEmpty)
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        SizedBox(height: 10),
                        Text(AppLocalizations.of(context).translate('sizes'), style: boldFonts(size: 18)),
                        SizedBox(height: 20),
                        SizeListView(list: mSizeList),
                        SizedBox(height: 20),
                      ])
                    else
                      SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context).translate('more_info'), style: boldFonts(size: 18)),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('height')),
                                Text(AppLocalizations.of(context).translate('width')),
                                Text(AppLocalizations.of(context).translate('length'))
                              ],
                            ),
                            VerticalDivider(width: 5),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                              Text('${widget.product.height.validate()} cm', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${widget.product.width.validate()} cm', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${widget.product.length.validate()} cm', style: TextStyle(fontWeight: FontWeight.bold))
                            ])
                          ]),
                        ),
                        SizedBox(height: 20),
                      ],
                    ).visible(widget.product.height.isNotEmpty),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductReviewScreen(mProductId: widget.product.pro_id)));
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[400])),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                AppLocalizations.of(context).translate('product_reviews'),
                                style: boldFonts(size: 16),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );

    List<T> map<T>(List list, Function handler) {
      List<T> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i, list[i]));
      }
      return result;
    }

    final carousel = Carousel(
      images: map<Widget>(
        widget.product.gallery,
        (index, i) {
          return InkWell(
            onTap: () => redirectUrl(widget.product.gallery[index]),
            child: Image.network(i, fit: BoxFit.cover, width: double.infinity),
          );
        },
      ).toList(),
      indicatorBgPadding: 3,
      boxFit: BoxFit.fitWidth,
      dotPosition: DotPosition.bottomLeft,
      autoplay: false,
    ).withSize(height: 200, width: MediaQuery.of(context).size.width);

    final collapsedBody = NestedScrollView(
      body: SingleChildScrollView(
        child: (widget.product != null) ? body : Container(),
      ),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: whiteColor,
            pinned: true,
            expandedHeight: 370,
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.product.gallery.isNotEmpty ? carousel : Image.network(widget.product.full.validate(), fit: BoxFit.cover),
              title: innerBoxIsScrolled ? Text(widget.product.name.validate(), style: TextStyle(color: blackColor)) : Text(''),
            ),
            actions: <Widget>[
              InkWell(
                onTap: () => onWishListTap(),
                child: Image.asset(mIsInWishList ? 'assets/ic_heart_filled.png' : 'assets/ic_heart.png', color: mIsInWishList ? Colors.redAccent : blackColor, width: 24, height: 24),
              ).paddingOnly(right: 16, top: 8),
              InkWell(
                onTap: () => CartScreen().launch(context),
                child: Badge(
                  badgeColor: blackColor,
                  badgeContent: Text(mCartCount.toString(), style: TextStyle(color: whiteColor)),
                  child: Icon(Icons.shopping_cart, color: Colors.black, size: 24),
                ),
              ).paddingOnly(right: 16, top: 8),
            ],
          )
        ];
      },
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          widget.product != null ? collapsedBody : Center(child: CircularProgressIndicator()),
          //if (widget.product != null) bottomButton
        ],
      ),
    );
  }
}

class SizeListView extends StatefulWidget {
  List<ColorSizeSelectionModel> list;

  SizeListView({Key key, this.list}) : super(key: key);

  @override
  SizeListViewState createState() => SizeListViewState();
}

class SizeListViewState extends State<SizeListView> {
  var primaryColor;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    primaryColor = await getThemeColor();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: widget.list.length,
          itemBuilder: (_, index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.list.forEach((item) {
                      item.isSelected = false;
                    });
                    if (widget.list[index].isSelected) {
                      widget.list[index].isSelected = false;
                    } else {
                      widget.list[index].isSelected = true;
                    }
                  });
                },
                child: widget.list[index].isSelected ? getSelectedSizeWidget(widget.list[index].name, primaryColor) : getSizeWidget(widget.list[index].name));
          }),
    );
  }
}

class ColorListView extends StatefulWidget {
  List<ColorSizeSelectionModel> list;

  ColorListView({Key key, this.list}) : super(key: key);

  @override
  ColorListViewState createState() => ColorListViewState();
}

class ColorListViewState extends State<ColorListView> {
  var primaryColor;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    primaryColor = await getThemeColor();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      height: 40,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: widget.list.length,
          itemBuilder: (_, index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.list.forEach((item) {
                      item.isSelected = false;
                    });
                    if (widget.list[index].isSelected) {
                      widget.list[index].isSelected = false;
                    } else {
                      widget.list[index].isSelected = true;
                    }
                  });
                },
                child: Container(child: widget.list[index].isSelected ? getSelectedColorWidget(widget.list[index].name, primaryColor) : getColorWidget(widget.list[index].name)));
          }),
    );
    return body;
  }
}
