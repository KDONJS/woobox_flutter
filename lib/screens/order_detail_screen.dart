import 'package:WooBox/model/OrderDataModel.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/dashed_ract.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class OrderDetailScreen extends StatelessWidget {
  static String tag = '/OrderDetailScreen';
  final OrderDataModel orderData;

  OrderDetailScreen({Key key, @required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget lineItems = ListView.builder(
      physics: ClampingScrollPhysics(),
      itemCount: orderData.line_items.length,
      shrinkWrap: true,
      itemBuilder: (_, index) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  orderData.line_items[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    PriceWidget(price: orderData.line_items[index].price.toString(), size: 20),
                    SizedBox(width: 5),
                    Text(
                      orderData.line_items[index].price.toString(),
                      style: TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 4, 8, 0),
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: DashedRect(
                            gap: 2,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 4, 8, 0),
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(convertDate(orderData.date_created)),
                        Text(orderData.status),
                        SizedBox(height: 35),
                        orderData.status == completed
                            ? Text('${AppLocalizations.of(context).translate('order_completed_on')} ${convertDate(orderData.date_completed)}')
                            : Text(
                                AppLocalizations.of(context).translate('item_delivering'),
                              ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    final body = Container(
      margin: EdgeInsets.all(16),
      child: orderData.line_items.isNotEmpty
          ? Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      decoration: boxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(AppLocalizations.of(context).translate('shipping_details'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          Divider(height: 5),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              children: <Widget>[Text(AppLocalizations.of(context).translate('order_id'), style: TextStyle(color: textSecondaryColor)), Text(orderData.id.toString())],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                              children: <Widget>[Text(AppLocalizations.of(context).translate('order_date'), style: TextStyle(color: textSecondaryColor)), Text(convertDate(orderData.date_created))],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.topLeft,
                      decoration: boxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(AppLocalizations.of(context).translate('payment_details'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          Divider(height: 5),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('offer'), style: TextStyle(fontSize: 18, color: Colors.black)),
                                Text(AppLocalizations.of(context).translate('offer_not_available'), style: boldFonts(color: Colors.orange))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('shipping_charge'), style: TextStyle(fontSize: 18, color: Colors.black)),
                                Text(AppLocalizations.of(context).translate('free'), style: boldFonts(color: Colors.green))
                              ],
                            ),
                          ),
                          orderData.payment_method_title.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Text('Payment Method - ', maxLines: 2, style: TextStyle(fontSize: 18, color: Colors.black)),
                                      Text(orderData.payment_method_title, style: boldFonts(color: Colors.green))
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context).translate('total_amount'), style: TextStyle(fontSize: 18, color: Colors.black)),
                                PriceWidget(price: '${getTotalAmount(orderData.line_items)}', size: 20)
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          //TODO
                          /*if (orderData.status == pending)
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: MaterialButton(
                                child: Text('Complete Payment'),
                                child: Text('Complete Payment'),
                                onPressed: () {
                                  toast('sss');
                                },
                              ),
                            )*/
                        ],
                      ),
                    )
                  ],
                )
              ],
            )
          : Container(),
    );

    return Scaffold(
      appBar: getAppBar(context, '${AppLocalizations.of(context).translate('order_num')}${orderData.id.toString()}'),
      body: SingleChildScrollView(
          child: Column(
            children: <Widget>[orderData.line_items.isNotEmpty ? Container(padding: EdgeInsets.all(16), child: lineItems) : Container(), body],
          ),
          physics: BouncingScrollPhysics()),
    );
  }
}

String getTotalAmount(List<LineItem> products) {
  var amount = 0.0;
  for (var ii = 0; ii < products.length; ii++) {
    amount += double.parse(products[ii].price.toString());
  }
  return amount.toString();
}
