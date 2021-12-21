import 'package:WooBox/model/CartModel.dart';
import 'package:WooBox/model/CreateOrderRequestModel.dart';
import 'package:WooBox/model/PaymentGatewayModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/home_screen.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';

class PaymentScreen extends StatefulWidget {
  static String tag = '/PaymentScreen';
  var mCartModel = List<CartModel>();
  CreateOrderRequestModel mCreateOrderRequestModel;

  PaymentScreen({Key key, this.mCartModel, this.mCreateOrderRequestModel}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  var mOrderId;
  var appName = '';
  var amount = '';
  var email = '';
  List<PaymentGatewayModel> mPaymentGatewayList = List<PaymentGatewayModel>();
  var mErrorMsg = '';
  var mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
    processPaymentApi();
  }

  getActivePaymentGateways() async {
    getActivePaymentGatewaysApi().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mPaymentGatewayList = list.map((model) => PaymentGatewayModel.fromJson(model)).toList();
        mErrorMsg = '';
      });
    }).catchError((error) {
      setState(() {
        mErrorMsg = error.toString();
      });
    });
  }

  init() async {
    setState(() {
      amount = getTotalAmount(widget.mCartModel);
    });
    await getString(USER_EMAIL).then((s) {
      setState(() {
        email = s;
      });
    });
    await PackageInfo.fromPlatform().then((p) {
      setState(() {
        appName = p.appName;
      });
    });
  }

  void createOrder({String paymentMethod, String txnId = ''}) async {
    setState(() {
      mIsLoading = true;
    });
    await createOrderApi(widget.mCreateOrderRequestModel.toJson()).then((response) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        mOrderId = response['id'];
        processPaymentApi(txnId: txnId);
      });
    }).catchError((error) {
      setState(() {
        mIsLoading = false;
      });
      toast(error.toString());
    });
  }

  processPaymentApi({String paymentMethod, String txnId = ''}) async {
    print(mOrderId);
    if (mOrderId == null) {
      createOrder(txnId: txnId);
      return;
    }
    var request = {'order_id': mOrderId};
    getCheckOutUrl(request).then((res) {
      if (!mounted) return;
      clearCartItems().then((response) {
        if (!mounted) return;
        setState(() {
          mIsLoading = false;
        });
        setCartCount(0);

        launchNewScreenWithNewTask(context, HomeScreen.tag);
        redirectUrl(res['checkout_url']);
      }).catchError((error) {
        setState(() {
          mIsLoading = false;
        });
        toast(error.toString());
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    Widget paymentDetailView = Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.all(16),
        decoration: boxDecoration(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Payment Details',
                style: boldFonts(size: 18),
              ),
              SizedBox(height: 10),
              Divider(height: 1),
              SizedBox(height: 10),
              Row(children: <Widget>[
                Text(
                  'Offer - ',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  'Offer not available',
                  style: TextStyle(fontSize: 18, color: Colors.deepOrangeAccent),
                )
              ]),
              Row(children: <Widget>[
                Text(
                  'Shipping Charge - ',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  'Free',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                )
              ]),
              Row(children: <Widget>[
                Text(
                  'Total Amount - ',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                PriceWidget(price: amount)
              ])
            ],
          ),
        ));

    Widget listView = ListView.separated(
        separatorBuilder: (context, index) {
          return Divider();
        },
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, i) {
          return InkWell(
              child: Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(mPaymentGatewayList[i].method_title, style: TextStyle(color: blackColor, fontSize: 18)),
                    ],
                  )),
              onTap: () {});
        },
        itemCount: 3);

    Widget body = Column(children: <Widget>[
      SizedBox(height: 16),
      mErrorMsg.isEmpty
          ? mPaymentGatewayList.isNotEmpty ? listView : Container(height: 100, child: Center(child: CircularProgressIndicator()))
          : Container(height: 100, child: Center(child: Text(mErrorMsg))),
      paymentDetailView
    ]);

    return Scaffold(
      appBar: getAppBar(context, 'Payment'),
      body: !mIsLoading ? SingleChildScrollView(child: body, physics: BouncingScrollPhysics()) : Center(child: CircularProgressIndicator()),
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
