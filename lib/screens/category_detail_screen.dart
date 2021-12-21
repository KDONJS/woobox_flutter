import 'package:WooBox/model/CategoryData.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryDetailScreen extends StatefulWidget {
  static String tag = '/CategoryDetail';
  final CategoryData mCategoryData;

  CategoryDetailScreen({Key key, @required this.mCategoryData}) : super(key: key);

  @override
  CategoryDetailScreenState createState() {
    return CategoryDetailScreenState();
  }
}

class CategoryDetailScreenState extends State<CategoryDetailScreen> {
  var mProductModel = List<ProductModelNew>();
  var mCategoryModel = List<CategoryData>();

  var errorMsgNewestProduct = "";
  var errorMsgFeaturedProduct = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    await getSubCategories(widget.mCategoryData.cat_ID).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mCategoryModel = list.map((model) => CategoryData.fromJson(model)).toList();
      });
    });

    List<int> category = [];
    category.add(widget.mCategoryData.cat_ID);
    Map request = {'category': category.toSet().toList()};

    filterProducts(request).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mProductModel = list.map((model) => ProductModelNew.fromJson(model)).toList();
        errorMsgNewestProduct = '';
      });
    }).catchError((error) {
      setState(() {
        mProductModel.clear();
        errorMsgNewestProduct = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget categoryListView = Container(
      height: productCategoryHeight,
      margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(8),
        itemCount: mCategoryModel.length,
        itemBuilder: (BuildContext context, int index) {
          return getCategoryWidget(context, mCategoryModel[index], index);
        },
      ),
    );

    Widget newestProductListView = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      scrollDirection: Axis.vertical,
      itemCount: mProductModel.length > 5 ? 5 : mProductModel.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => ProductDetail(product: mProductModel[index]).launch(context),
          child: getProductWidget(mProductModel[index], width: context.width() / 2),
        );
      },
    );

    return Scaffold(
      appBar: getAppBar(context, widget.mCategoryData.name),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            mCategoryModel.isNotEmpty ? Column(children: <Widget>[SizedBox(height: 20), categoryListView]) : Container(),
            errorMsgNewestProduct.isEmpty
                ? mProductModel.isNotEmpty ? newestProductListView : Container(height: 250, padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()))
                : Container(height: 250, child: Center(child: Text(errorMsgNewestProduct)))
          ],
        ),
      ),
    );
  }
}
