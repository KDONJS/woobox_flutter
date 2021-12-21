import 'package:WooBox/model/OrderDataModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/dashed_ract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../app_localizations.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  static String tag = '/MyOrders';

  @override
  MyOrdersScreenState createState() {
    return MyOrdersScreenState();
  }
}

class MyOrdersScreenState extends State<MyOrdersScreen> {
  var mOrderListModel = List<OrderDataModel>();
  var mErrorMsg = '';

  var scrollController = new ScrollController();
  bool isLoading = false;
  int page = 1;
  bool isLastPage = false;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      scrollHandler();
    });
    fetchData(page);
  }

  Future fetchData(page) async {
    await getOrders(page: page).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable list = res;
        mOrderListModel.addAll(list.map((model) => OrderDataModel.fromJson(model)).toList());
        if (mOrderListModel.isEmpty) {
          mErrorMsg = AppLocalizations.of(context).translate('no_orders_found');
          isLastPage = true;
        } else {
          mErrorMsg = '';
          isLastPage = false;
        }
      });
    }).catchError((error) {
      setState(() {
        isLastPage = true;
        mOrderListModel.clear();
        mErrorMsg = error.toString();
      });
    });
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLastPage) {
      page++;
      fetchData(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      shrinkWrap: true,
      controller: scrollController,
      itemCount: mOrderListModel.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(orderData: mOrderListModel[index])))},
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: productContainerBgColor,
            child: mOrderListModel[index].line_items.isNotEmpty
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            mOrderListModel[index].line_items.isNotEmpty
                                ? Text(
                                    mOrderListModel[index].line_items[0].name != null ? mOrderListModel[index].line_items[0].name : Text(''),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  )
                                : Text(''),
                            SizedBox(height: 5),
                            mOrderListModel[index].line_items.isNotEmpty ? PriceWidget(price: mOrderListModel[index].line_items[0].price.toString(), size: 20) : Text(''),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(margin: EdgeInsets.fromLTRB(8, 4, 8, 0), height: 10, width: 10, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16))),
                                    SizedBox(
                                      height: 50,
                                      child: DashedRect(
                                        gap: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                        margin: EdgeInsets.fromLTRB(8, 4, 8, 0), height: 10, width: 10, decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(16))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(mOrderListModel[index].date_created != null ? convertDate(mOrderListModel[index].date_created) : ''),
                                    Text(mOrderListModel[index].status),
                                    SizedBox(height: 30),
                                    mOrderListModel[index].status == completed
                                        ? Text('${AppLocalizations.of(context).translate('order_completed_on')} ${convertDate(mOrderListModel[index].date_completed)}')
                                        : Text(AppLocalizations.of(context).translate('item_delivering')),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  )
                : Container(),
          ),
        );
      },
    );

    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('my_orders')),
      body: mErrorMsg.isEmpty
          ? mOrderListModel.isNotEmpty
              ? SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: listView,
                )
              : Center(child: CircularProgressIndicator())
          : Center(child: Text(mErrorMsg)),
    );
  }
}
