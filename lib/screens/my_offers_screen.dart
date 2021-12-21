import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/utils/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';

class MyOffersScreen extends StatefulWidget {
  static String tag = '/MyOffersScreen';

  @override
  MyOffersScreenState createState() => MyOffersScreenState();
}

class MyOffersScreenState extends State<MyOffersScreen> {
  var mProductModel = List<ProductModelNew>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    await getMyOffers().then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mProductModel = list.map((model) => ProductModelNew.fromJson(model)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      children: <Widget>[
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: mProductModel.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => ProductDetail(product: mProductModel[index]).launch(context),
              child: getProductWidget(mProductModel[index], width: context.width() / 2),
            );
          },
        ),
        SizedBox(height: 16)
      ],
    );

    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('special_offers')),
      body: Center(
        child: SingleChildScrollView(
          child: mProductModel.isNotEmpty ? body : CircularProgressIndicator().paddingAll(8),
        ),
      ),
    );
  }
}
