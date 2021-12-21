import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nb_utils/nb_utils.dart';

import 'common.dart';
import 'constants.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final darkMode;

  CustomContainer(this.darkMode, this.child);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: child,
      decoration: boxDecorationSoftUI(darkMode: darkMode),
    );
  }
}

Widget getLoadingProgress(loadingProgress) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
      ),
    ),
  );
}

Widget getColorWidget(String strings) {
  return new Container(
    margin: EdgeInsets.only(right: 8),
    padding: const EdgeInsets.all(8),
    decoration: boxDecoration(color: whiteColor),
    alignment: Alignment.center,
    child: Text(strings),
  );
}

Widget getSelectedColorWidget(String strings, primaryColor) {
  return new Container(
    decoration: boxDecoration(bgColor: primaryTransColor, color: primaryColor),
    margin: EdgeInsets.only(right: 8),
    padding: const EdgeInsets.only(left: 8, right: 8),
    alignment: Alignment.center,
    child: Text(strings, style: TextStyle(color: primaryColor)),
  );
}

Widget getSizeWidget(String strings) {
  return Container(margin: EdgeInsets.only(right: 8), padding: const EdgeInsets.all(8), decoration: boxDecoration(color: whiteColor), alignment: Alignment.center, child: Text(strings));
}

Widget getSelectedSizeWidget(String strings, primaryColor) {
  return Container(
    margin: EdgeInsets.only(right: 8),
    padding: const EdgeInsets.only(left: 8, right: 8),
    decoration: boxDecoration(bgColor: primaryTransColor, color: primaryColor),
    alignment: Alignment.center,
    child: new Text(strings, style: TextStyle(color: primaryColor)),
  );
}

class PriceWidget extends StatefulWidget {
  static String tag = '/PriceWidget';
  var price;
  var size = 22.0;
  Color color;
  var isLineThroughEnabled = false;

  PriceWidget({Key key, this.price, this.color, this.size, this.isLineThroughEnabled = false}) : super(key: key);

  @override
  PriceWidgetState createState() => PriceWidgetState();
}

class PriceWidgetState extends State<PriceWidget> {
  var currency = '€';
  Color primaryColor;

  @override
  void initState() {
    super.initState();
    get();
  }

  get() async {
    primaryColor = await getThemeColor();
    await getSharedPref().then((pref) {
      if (pref.get(DEFAULT_CURRENCY) != null) {
        setState(() {
          currency = pref.getString(DEFAULT_CURRENCY);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLineThroughEnabled) {
      return Text('$currency${widget.price.toString()}', style: boldFonts(size: widget.size, color: widget.color != null ? widget.color : primaryColor));
    } else {
      return widget.price.toString().isNotEmpty
          ? Text('$currency${widget.price.toString()}', style: TextStyle(fontSize: widget.size, color: widget.color ?? textPrimaryColor, decoration: TextDecoration.lineThrough))
          : Text('');
    }
  }
}

class BuildAlertDialog extends StatelessWidget {
  var message;
  var onPositiveClick;

  BuildAlertDialog(this.message, this.onPositiveClick);

  @override
  Widget build(BuildContext context) {
    return alertDialog(context, message, onPositiveClick);
  }
}

alertDialog(context, message, Function onPositiveClick, {String title = 'Confirmation', positiveButton = 'Yes', negativeButton = 'No'}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text(negativeButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
              child: Text(positiveButton),
              onPressed: () {
                Navigator.of(context).pop();
                onPositiveClick;
              }),
        ],
      );
    },
  );
}

Widget ratingBarWidget(double ratings, {itemSize = 20.0}) {
  return RatingBar(
    initialRating: ratings,
    direction: Axis.horizontal,
    allowHalfRating: false,
    tapOnlyMode: true,
    ignoreGestures: true,
    itemCount: 5,
    itemSize: itemSize,
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: Colors.amber,
    ),
    onRatingUpdate: (rating) {},
  );
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction> showConfirmDialogs(context, msg, positiveText, negativeText) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(msg, style: TextStyle(fontSize: 16)),
        actions: <Widget>[
          FlatButton(
            child: Text(negativeText),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: Text(positiveText),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}
