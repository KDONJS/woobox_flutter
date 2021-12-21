import 'dart:convert';

import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/ProductAttributeModel.dart';
import 'package:WooBox/model/ProductModelNew.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/product_detail_screen.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nb_utils/nb_utils.dart';

class ViewAllProductScreen extends StatefulWidget {
  static String tag = '/ViewAllProductScreen';

  @override
  ViewAllProductScreenState createState() {
    return ViewAllProductScreenState();
  }
}

class ViewAllProductScreenState extends State<ViewAllProductScreen> {
  var sortType = -1;
  var mProductModel = List<ProductModelNew>();
  ProductAttributeModel mProductAttributeModel;
  var isListViewSelected = false;
  var errorMsg = '';

  var scrollController = new ScrollController();
  bool isLoading = false;
  bool isLoadingMoreData = false;
  int page = 1;
  bool isLastPage = false;

  var primaryColor;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  sortByPrice(sortByLowToHigh) async {
    setState(() {
      if (sortByLowToHigh) {
        mProductModel.sort((a, b) {
          return double.parse(a.price).toDouble().compareTo(double.parse(b.price).toDouble());
        });
        sortType = 1;
      } else {
        mProductModel.sort((b, a) {
          return double.parse(a.price).toDouble().compareTo(double.parse(b.price).toDouble());
        });
        sortType = 2;
      }
    });
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLastPage) {
      page++;
      loadMoreData(page);
    }
  }

  Future loadMoreData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    await getProducts(page).then((res) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        Iterable list = res;
        mProductModel.addAll(list.map((model) => ProductModelNew.fromJson(model)).toList());
        isLastPage = false;
        if (sortType == 1) {
          sortByPrice(true);
        } else if (sortType == 2) {
          sortByPrice(false);
        }
      });
    }).catchError((error) {
      setState(() {
        isLastPage = true;
        isLoadingMoreData = false;
      });
    });
  }

  Future fetchData() async {
    primaryColor = await getThemeColor();
    setState(() {
      isLoading = true;
    });
    await getProducts(1).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mProductModel = list.map((model) => ProductModelNew.fromJson(model)).toList();
      });
    }).catchError((error) {});
    getProductsAttributes().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mProductAttributeModel = ProductAttributeModel.fromJson(res);
      });
    }).catchError((error) {});
  }

  Future filterProduct(var request) async {
    filterProducts(request).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mProductModel = list.map((model) => ProductModelNew.fromJson(model)).toList();
        errorMsg = '';
      });
    }).catchError((error) {
      setState(() {
        errorMsg = error.toString();
      });
    });
  }

  void onListClick(which) {
    setState(() {
      if (which == 1) {
        isListViewSelected = true;
      } else if (which == 2) {
        isListViewSelected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget collectionLabel = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('collections_2020'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Sort by high to low price',
                icon: Icon(Icons.arrow_upward, color: inactiveColor),
                onPressed: () {
                  sortByPrice(false);
                },
              ),
              IconButton(tooltip: 'Sort by low to high price', icon: Icon(Icons.arrow_downward, color: inactiveColor), onPressed: () => {sortByPrice(true)}),
              IconButton(icon: Icon(Icons.grid_on, color: isListViewSelected ? inactiveColor : primaryColor), onPressed: () => {onListClick(2)}),
              IconButton(icon: Icon(Icons.view_list, color: isListViewSelected ? primaryColor : inactiveColor), onPressed: () => {onListClick(1)})
            ],
          )
        ],
      ),
    );

    Widget listView = Container(
      child: ListView.builder(
        itemCount: mProductModel.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => ProductDetail(product: mProductModel[index]).launch(context),
            child: Container(
              padding: EdgeInsets.all(10.0),
              width: context.width(),
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(mProductModel[index].full.validate(), fit: BoxFit.cover, height: 170, width: 130),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${mProductModel[index].name} ${mProductModel[index].name} ${mProductModel[index].name}',
                            style: boldTextStyle(size: 18),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            PriceWidget(price: mProductModel[index].sale_price.validate().isNotEmpty ? mProductModel[index].sale_price.toString() : mProductModel[index].price.validate(), size: 20),
                            PriceWidget(price: mProductModel[index].regular_price.validate(), size: 16, color: textSecondaryColor, isLineThroughEnabled: true)
                                .visible(mProductModel[index].sale_price.validate().isNotEmpty),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4, bottom: 4),
                          padding: EdgeInsets.all(4),
                          child: RatingBar(
                            initialRating: double.parse(mProductModel[index].average_rating),
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            tapOnlyMode: true,
                            itemCount: 5,
                            itemSize: 18,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                        ),
                        Row(children: colorWidget(mProductModel[index].color.validate())),
                        Row(children: sizeWidget(mProductModel[index].size.validate())),
                        SizedBox(height: 4),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );

    Widget gridView = Container(
      child: GridView.builder(
        itemCount: mProductModel.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (_, index) {
          return InkWell(
            onTap: () => ProductDetail(product: mProductModel[index]).launch(context),
            child: getProductWidget(mProductModel[index], width: context.width() / 2),
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: blackColor), onPressed: () => finish(context)),
        backgroundColor: whiteColor,
        title: Text(AppLocalizations.of(context).translate('view_all'), style: TextStyle(color: blackColor)),
        actions: <Widget>[IconButton(icon: Icon(Icons.filter_list, color: blackColor), onPressed: () => showMyBottomSheet(context))],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: <Widget>[
            collectionLabel,
            errorMsg.isEmpty
                ? Center(
                    child: mProductModel.isNotEmpty
                        ? Column(children: <Widget>[isListViewSelected ? listView : gridView, CircularProgressIndicator().visible(isLoadingMoreData)])
                        : CircularProgressIndicator().paddingAll(8),
                  )
                : Center(child: Text(errorMsg)),
          ],
        ),
      ),
    );
  }

  void showMyBottomSheet(context) {
    if (mProductAttributeModel == null) return;
    void onSave(List<int> category, List<String> size, List<String> color, List<String> brand) {
      Map request = {
        'category': category.toSet().toList(),
        'size': size.toSet().toList(),
        'color': color.toSet().toList(),
        'brand': brand.toSet().toList(),
      };
      if (category.length < 1) request.remove('category');
      if (size.length < 1) request.remove('size');
      if (color.length < 1) request.remove('color');
      if (brand.length < 1) request.remove('brand');

      filterProduct(jsonEncode(request));
    }

    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return FilterBottomSheetLayout(mProductAttributeModel: mProductAttributeModel, onSave: onSave);
        },
        fullscreenDialog: true));
  }

  List<Widget> sizeWidget(String size) {
    var maxWidget = 2;
    var currentIndex = 0;
    List<Widget> list = List();
    var totalSize = size.split(',').length;
    var flag = false;

    size.split(',').forEach((size) {
      if (currentIndex < maxWidget) {
        list.add(getSizeWidget(size.trim()));
        currentIndex++;
      } else {
        if (!flag) list.add(Text('+ ${totalSize - maxWidget} more'));
        flag = true;
        return;
      }
    });
    return list;
  }

  List<Widget> colorWidget(String color) {
    var maxWidget = 2;
    var currentIndex = 0;
    List<Widget> list = List();
    var totalColors = color.split(',').length;
    var flag = false;

    color.split(',').forEach((color) {
      if (currentIndex < maxWidget) {
        list.add(getColorWidget(color.trim()));
        currentIndex++;
      } else {
        if (!flag) list.add(Text('+ ${totalColors - maxWidget} more'));
        flag = true;
        return;
      }
    });
    return list;
  }
}

class FilterBottomSheetLayout extends StatefulWidget {
  ProductAttributeModel mProductAttributeModel;
  var onSave;

  FilterBottomSheetLayout({Key key, this.mProductAttributeModel, this.onSave}) : super(key: key);

  @override
  FilterBottomSheetLayoutState createState() {
    return FilterBottomSheetLayoutState();
  }
}

class FilterBottomSheetLayoutState extends State<FilterBottomSheetLayout> {
  List<int> selectedCategories = List();
  List<String> selectedColors = List();
  List<String> selectedSizes = List();
  List<String> selectedBrands = List();

  @override
  Widget build(BuildContext context) {
    var categoryList = widget.mProductAttributeModel.categories;
    var colorsList = widget.mProductAttributeModel.colors;
    var sizesList = widget.mProductAttributeModel.sizes;
    var brandsList = widget.mProductAttributeModel.brands;

    /*categoryList.forEach((item) {
      item.isSelected = false;
    });
    colorsList.forEach((item) {
      item.isSelected = false;
    });
    sizesList.forEach((item) {
      item.isSelected = false;
    });
    brandsList.forEach((item) {
      item.isSelected = false;
    });*/
    //TODO Set previously selected filters
    /*for (var i = 0; i < categoryList.length; i++) {
      if (categoryList[i].isSelected) {
        selectedCategories.add(categoryList[i].cat_ID);
      }
    }
    for (var i = 0; i < colorsList.length; i++) {
      if (colorsList[i].isSelected) {
        selectedColors.add(colorsList[i].name);
      }
    }
    for (var i = 0; i < sizesList.length; i++) {
      if (sizesList[i].isSelected) {
        selectedSizes.add(sizesList[i].name);
      }
    }
    for (var i = 0; i < brandsList.length; i++) {
      if (brandsList[i].isSelected) {
        selectedBrands.add(brandsList[i].name);
      }
    }*/

    final productCategoryListView = ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: categoryList?.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              label: Text(categoryList[index].name, style: TextStyle(color: categoryList[index].isSelected ? Colors.red : blackColor)),
              selected: categoryList[index].isSelected,
              onSelected: (selected) {
                setState(() {
                  categoryList[index].isSelected ? categoryList[index].isSelected = false : categoryList[index].isSelected = true;
                });
              },
              elevation: 2,
              backgroundColor: Colors.white10,
              selectedColor: primaryTransColor,
            ),
          );
        });

    final productColorsListView = ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: colorsList?.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              label: Text(colorsList[index].name, style: TextStyle(color: colorsList[index].isSelected ? Colors.red : blackColor)),
              selected: colorsList[index].isSelected,
              onSelected: (selected) {
                setState(() {
                  colorsList[index].isSelected ? colorsList[index].isSelected = false : colorsList[index].isSelected = true;
                });
              },
              elevation: 2,
              backgroundColor: Colors.white10,
              selectedColor: primaryTransColor,
            ),
          );
        });

    final productSizeListView = ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: sizesList?.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              label: Text(sizesList[index].name, style: TextStyle(color: sizesList[index].isSelected ? Colors.red : blackColor)),
              selected: sizesList[index].isSelected,
              onSelected: (selected) {
                setState(() {
                  sizesList[index].isSelected ? sizesList[index].isSelected = false : sizesList[index].isSelected = true;
                });
              },
              elevation: 2,
              backgroundColor: Colors.white10,
              selectedColor: primaryTransColor,
            ),
          );
        });

    final productBrandsListView = ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: brandsList?.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              label: Text(brandsList[index].name, style: TextStyle(color: brandsList[index].isSelected ? Colors.red : blackColor)),
              selected: brandsList[index].isSelected,
              onSelected: (selected) {
                setState(() {
                  brandsList[index].isSelected ? brandsList[index].isSelected = false : brandsList[index].isSelected = true;
                });
              },
              elevation: 2,
              backgroundColor: Colors.white10,
              selectedColor: primaryTransColor,
            ),
          );
        });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('filter')),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                for (var i = 0; i < categoryList.length; i++) {
                  if (categoryList[i].isSelected) {
                    selectedCategories.add(categoryList[i].cat_ID);
                  }
                }
                for (var i = 0; i < colorsList.length; i++) {
                  if (colorsList[i].isSelected) {
                    selectedColors.add(colorsList[i].name);
                  }
                }
                for (var i = 0; i < sizesList.length; i++) {
                  if (sizesList[i].isSelected) {
                    selectedSizes.add(sizesList[i].name);
                  }
                }
                for (var i = 0; i < brandsList.length; i++) {
                  if (brandsList[i].isSelected) {
                    selectedBrands.add(brandsList[i].name);
                  }
                }
                widget.onSave(selectedCategories, selectedSizes, selectedColors, selectedBrands);
                finish(context);
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(AppLocalizations.of(context).translate('category'), style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            Container(child: productCategoryListView, height: 50),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(AppLocalizations.of(context).translate('color'), style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            Container(child: productColorsListView, height: 50),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(AppLocalizations.of(context).translate('size'), style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            Container(child: productSizeListView, height: 50),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(AppLocalizations.of(context).translate('brand'), style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            Container(child: productBrandsListView, height: 50)
          ],
        ),
      ),
    );
  }
}
