import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/CartModel.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/quantity_stepper.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:nb_utils/nb_utils.dart';

import 'order_summary_screen.dart';

class CartFragment extends StatefulWidget {
  @override
  CartFragmentState createState() {
    return CartFragmentState();
  }
}

class CartFragmentState extends State<CartFragment> with AfterLayoutMixin<CartFragment> {
  var mCartModel = List<CartModel>();
  var mErrorMsg = '';
  var primaryColor;
  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  Future fetchData() async {
    primaryColor = await getThemeColor();
    setState(() {});
    await getCartList().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mCartModel = list.map((model) => CartModel.fromJson(model)).toList();
        mErrorMsg = '';
        setCartCount(mCartModel.length);
      });
    }).catchError((error) {
      setState(() {
        mCartModel.clear();
        mErrorMsg = error;
        setCartCount(0);
      });
    });
  }

  Future addToCartApi(aRequest) async {
    addToCart(aRequest).then((res) {
      toast(res[msg]);
      fetchData();
    }).catchError((error) {
      toast(error.toString());
    });
  }

  Future updateCartItemApi(request) async {
    updateCartItem(request).then((res) {
      toast(res[msg]);
      fetchData();
    }).catchError((error) {
      toast(error.toString());
    });
  }

  Future removeCartItemApi(pro_id) async {
    var request = {
      'pro_id': pro_id,
    };

    removeCartItem(request).then((res) {
      fetchData();
    }).catchError((error) {});
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

  @override
  Widget build(BuildContext context) {
    void onStepperValueChanged(int value, pro_id, cart_id) {
      setState(() {
        print(value.toString());
        var request = {
          'pro_id': pro_id,
          'cart_id': cart_id,
          'quantity': value,
          'color': '',
          'size': '',
        };
        updateCartItemApi(request);
      });
    }

    void clearCart() async {
      toast('Clearance is in progress');
      bool res = await showConfirmDialog(context, 'Are you sure want to clear cart?');

      if (res ?? false) {
        await clearCartItems().then((res) {
          if (!mounted) return;
          fetchData();
        }).catchError((error) {
          toast(error.toString());
        });
      }
    }

    final cartListView = ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: mCartModel.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => {handleProductClick(mCartModel[index].pro_id)},
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              color: productContainerBgColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(mCartModel[index].full, fit: BoxFit.cover, height: 180, width: 150),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          mCartModel[index].name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Text(AppLocalizations.of(context).translate('qty'), style: drawerTextStyle),
                            SizedBox(width: 10),
                            Container(
                              width: 100,
                              margin: EdgeInsets.fromLTRB(0, 8, 16, 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  StepperTouch(
                                    initialValue: int.parse(mCartModel[index].quantity),
                                    withSpring: true,
                                    onChanged: (value) => setState(() {
                                      mCartModel[index].quantity = value.toString();
                                      onStepperValueChanged(value, mCartModel[index].pro_id, mCartModel[index].cart_id);
                                    }),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 5),
                        PriceWidget(price: '${int.parse(mCartModel[index].price) * int.parse(mCartModel[index].quantity)}', size: 20),
                        SizedBox(height: 10),
                        Divider(height: 1),
                        FlatButton.icon(onPressed: () => {removeCartItemApi(mCartModel[index].pro_id)}, icon: Icon(Icons.delete_outline), label: Text(AppLocalizations.of(context).translate('remove')))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });

    final paymentDetailView = Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.all(16),
        decoration: boxDecoration(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate('payment_details'),
                style: boldFonts(size: 18),
              ),
              SizedBox(height: 10),
              Divider(height: 1),
              SizedBox(height: 10),
              Row(children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('offer'),
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  AppLocalizations.of(context).translate('offer_not_available'),
                  style: TextStyle(fontSize: 18, color: Colors.deepOrangeAccent),
                )
              ]),
              Row(children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('shipping_charge'),
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  AppLocalizations.of(context).translate('free'),
                  style: TextStyle(fontSize: 18, color: Colors.red),
                )
              ]),
              Row(children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('total_amount'),
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                PriceWidget(price: '${getTotalAmount(mCartModel)}', color: Colors.green, size: 20),
              ]),
              MaterialButton(
                minWidth: double.infinity,
                color: primaryColor,
                child: Text(AppLocalizations.of(context).translate('continue'), style: boldFonts(color: whiteColor)),
                onPressed: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => OrderSummaryScreen(cartList: mCartModel)));
                  OrderSummaryScreen(cartList: mCartModel).launch(context);
                },
              )
            ],
          ),
        ));

    final body = Column(
      children: <Widget>[
        Container(
          decoration: boxDecoration(bgColor: productBgColor),
          margin: EdgeInsets.only(left: 16, bottom: 16, right: 16),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Items: (${mCartModel.length})', style: boldFonts()),
              InkWell(
                  onTap: () {
                    clearCart();
                  },
                  child: Text('Clear Cart', style: boldFonts(color: Colors.redAccent)))
            ],
          ),
        ),
        cartListView,
        paymentDetailView,
      ],
    );

    return Scaffold(
      body: mErrorMsg.isEmpty
          ? mCartModel.isNotEmpty
              ? SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(children: <Widget>[
                    SizedBox(height: 16),
                    !mIsLoading ? body : Stack(alignment: Alignment.center, children: <Widget>[body, Center(child: CircularProgressIndicator())]),
                  ]),
                )
              : Center(child: CircularProgressIndicator())
          : Center(child: Text(mErrorMsg)),
    );
  }
}

String getTotalAmount(List<CartModel> products) {
  var amount = 0.0;
  for (var i = 0; i < products.length; i++) {
    amount += (double.parse(products[i].price) * double.parse(products[i].quantity));
  }
  return amount.toString();
}
