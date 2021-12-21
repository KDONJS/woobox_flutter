import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/AddressModel.dart';
import 'package:WooBox/model/CartModel.dart';
import 'package:WooBox/model/CreateOrderRequestModel.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/address_manager_screen.dart';
import 'package:WooBox/screens/payment_screen.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderSummaryScreen extends StatefulWidget {
  static String tag = '/OrderSummaryScreen';
  List<CartModel> cartList;

  OrderSummaryScreen({Key key, @required this.cartList}) : super(key: key);

  @override
  OrderSummaryScreenState createState() => OrderSummaryScreenState();
}

class OrderSummaryScreenState extends State<OrderSummaryScreen> {
  var mErrorMsg = '';
  AddressModel selectedAddressModel;
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

  Future fetchData() async {
    await getCartList().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        widget.cartList = list.map((model) => CartModel.fromJson(model)).toList();
        mErrorMsg = '';
      });
    }).catchError((error) {
      toast(error.toString());
      setState(() {
        mErrorMsg = error;
        widget.cartList.clear();
      });
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

  Future createOrderApi(AddressModel addressModel) async {
    if (!accessAllowed) {
      toast(demoPurposeMsg);
      return;
    }
    if (addressModel == null) {
      toast(AppLocalizations.of(context).translate('choose_one_address'));
      return;
    }
    selectedAddressModel = addressModel;
    var userEmail = await getString(USER_EMAIL);

    var request = CreateOrderRequestModel();

    var lineItems = List<LineItemsRequest>();
    widget.cartList.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.product_id = item.pro_id;
      lineItem.quantity = item.quantity;
      lineItem.variation_id = item.pro_id;

      lineItems.add(lineItem);
    });

    var billingItems = List<BillingShippingRequest>();

    var billingItem = BillingShippingRequest();
    billingItem.first_name = addressModel.first_name;
    billingItem.last_name = addressModel.last_name;
    billingItem.address_1 = addressModel.address_1;
    billingItem.address_2 = addressModel.address_2;
    billingItem.city = addressModel.city;
    billingItem.state = addressModel.state;
    billingItem.postcode = addressModel.postcode;
    billingItem.country = addressModel.country;
    billingItem.email = userEmail;
    billingItem.phone = addressModel.contact;

    billingItems.add(billingItem);

    request.line_items = lineItems;
    request.shipping = billingItems;

    var pref = await getSharedPref();
    request.customer_id = pref.getInt(USER_ID);

    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(mCartModel: widget.cartList, mCreateOrderRequestModel: request), maintainState: false));
  }

  Future removeCartItemApi(pro_id) async {
    var request = {
      'pro_id': pro_id,
    };

    removeCartItem(request).then((res) {
      fetchData();
    }).catchError((error) {});
  }

  void onOrderNowClick() async {
    ConfirmAction res = await showConfirmDialogs(context, 'Are you sure want to complete the order payment?', 'Yes', 'Cancel');

    if (res == ConfirmAction.ACCEPT) {
      if (selectedAddressModel == null) {
        selectedAddressModel = await getAddressFrom();
      } else {
        createOrderApi(selectedAddressModel);
      }
    }
  }

  void onChangeAddressClick() async {
    AddressModel addressModel = await getAddressFrom();
    setState(() {
      selectedAddressModel = addressModel;
    });
  }

  Future getAddressFrom() async {
    AddressModel addressModel = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddressManagerScreen()));
    return addressModel;
  }

  @override
  Widget build(BuildContext context) {
    final selectedAddress = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('${AppLocalizations.of(context).translate('delivered_to')}\n', style: TextStyle(fontSize: 18)),
        Text(selectedAddressModel == null ? '' : selectedAddressModel.first_name, style: boldFonts(size: 18)),
        //if (selectedAddressModel != null && selectedAddressModel.addressType.isNotEmpty) Text(selectedAddressModel.addressType),
        SizedBox(height: 5),
        Text(
          selectedAddressModel == null ? '' : selectedAddressModel.address_1,
        ),
        SizedBox(height: 5),
        Text(selectedAddressModel == null ? '' : selectedAddressModel.contact),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.bottomRight,
          child: MaterialButton(
              color: primaryColor,
              textColor: whiteColor,
              onPressed: () {
                onChangeAddressClick();
              },
              child: Text(AppLocalizations.of(context).translate('change_address'))),
        )
      ],
    );

    final cartListView = ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: widget.cartList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              handleProductClick(widget.cartList[index].pro_id);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              color: productContainerBgColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(widget.cartList[index].full, fit: BoxFit.cover, height: 180, width: 150),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.cartList[index].name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Text(AppLocalizations.of(context).translate('qty'), style: drawerTextStyle),
                            SizedBox(width: 10),
                            Text(widget.cartList[index].quantity, style: drawerTextStyle),
                          ],
                        ),
                        SizedBox(height: 10),
                        PriceWidget(price: '${int.parse(widget.cartList[index].price) * int.parse(widget.cartList[index].quantity)}', size: 20),
                        SizedBox(height: 10),
                        Divider(height: 1),
                        FlatButton.icon(
                            onPressed: () => {removeCartItemApi(widget.cartList[index].pro_id)}, icon: Icon(Icons.delete_outline), label: Text(AppLocalizations.of(context).translate('remove')))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });

    final bottomView = Container(
      decoration: boxDecoration(),
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: 16, right: 16),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('total_amount_lbl'),
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                PriceWidget(price: '${getTotalAmount(widget.cartList)}', size: 20)
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: MaterialButton(
              onPressed: () {
                onOrderNowClick();
              },
              color: primaryColor,
              child: Text(AppLocalizations.of(context).translate('order_now'), style: boldFonts(color: whiteColor)),
            ),
          )
        ],
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        selectedAddressModel == null ? Container() : Container(width: double.infinity, child: selectedAddress, padding: EdgeInsets.all(16), margin: EdgeInsets.all(16), color: productBgColor),
        cartListView,
        SizedBox(height: 30),
        bottomView
      ],
    );

    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('order_summary')),
      body: SingleChildScrollView(child: body, physics: BouncingScrollPhysics()),
    );
  }

  handleProductClick(productId) async {
    await getSingleProducts(productId).then((res) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetail(product: ProductModelNew.fromJson(res))));
    }).catchError((error) {
      toast(error.toString());
    });
  }

  String getTotalAmount(List<CartModel> products) {
    var amount = 0.0;
    for (var i = 0; i < products.length; i++) {
      amount += (double.parse(products[i].price) * double.parse(products[i].quantity));
    }
    return amount.toString();
  }
}
