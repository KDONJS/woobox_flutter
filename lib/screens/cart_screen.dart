import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/screens/cart_fragment.dart';
import 'package:WooBox/utils/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  static String tag = '/CartScreen';

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('cart')),
      body: CartFragment(),
    );
  }
}
