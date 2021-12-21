import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/searchbar.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static String tag = '/SearchScreen';

  @override
  SearchScreenState createState() {
    return SearchScreenState();
  }
}

class SearchScreenState extends State<SearchScreen> {
  var mCurrentPage = '0';
  var mProductModel = List<ProductModelNew>();
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

  void onTextChange(String value) async {
    var request = {
      'text': value,
      'page': mCurrentPage,
    };
    await searchProduct(request).then((res) {
      if (!mounted) return;
      setState(() {
        print(res);
        if (!mounted) return;
        setState(() {
          Iterable list = res;
          mProductModel = list.map((model) => ProductModelNew.fromJson(model)).toList();
        });
      });
    }).catchError((error) {
      print(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(
      children: <Widget>[
        SearchBar(hintText: AppLocalizations.of(context).translate('search_product'), onTextChange: onTextChange),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: mProductModel.length,
              itemBuilder: (_, index) {
                return InkWell(
                  onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetail(product: mProductModel[index])))},
                  child: new Container(
                    padding: const EdgeInsets.all(10.0),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.network(mProductModel[index].full, fit: BoxFit.cover, height: 150, width: 130),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              mProductModel[index].name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Row(
                              children: <Widget>[Text(mProductModel[index].average_rating), IconButton(icon: Icon(Icons.star, color: primaryColor, size: 18), onPressed: () => {})],
                            ),
                            //getColorWidgets(mProductModel[index].color),
                            //getSizeWidgets(mProductModel[index].size),
                            PriceWidget(price: mProductModel[index].price.toString()),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );

    return Scaffold(
      body: SafeArea(child: body),
    );
  }
}
