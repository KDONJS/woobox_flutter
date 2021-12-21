import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/AddressModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/screens/add_new_address.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressManagerScreen extends StatefulWidget {
  static String tag = '/AddressManagerScreen';

  @override
  AddressManagerScreenState createState() => AddressManagerScreenState();
}

class AddressManagerScreenState extends State<AddressManagerScreen> {
  var mAddressModel = List<AddressModel>();
  var selectedAddressIndex = -1;
  var primaryColor;
  var mIsLoading = true;

  @override
  void initState() {
    super.initState();
    init();
    getAddress();
  }

  init() async {
    primaryColor = await getThemeColor();

    getAddress();
  }

  Future getAddress() async {
    setState(() {
      mIsLoading = true;
    });
    await getAddressApi().then((res) {
      Iterable list = res;
      mAddressModel = list.map((model) => AddressModel.fromJson(model)).toList();
      setState(() {
        mIsLoading = false;
      });
    }).catchError((error) {
      toast(error.toString());
      setState(() {
        mIsLoading = false;
      });
    });

    /*setState(() {
      dynamic json = jsonDecode(pref.getString(STORED_ADDRESSES));
      print(json);
      Iterable list = json;
      mAddressModel = list.map((model) => AddressModel.fromJson(model)).toList();
    });*/
  }

  deleteAddress(AddressModel model) async {
    mAddressModel.remove(model);

    setState(() {});
    await deleteAddressApi({'ID': model.ID}).then((value) {}).catchError((error) {
      getAddress();
      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.separated(
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemBuilder: (item, index) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.redAccent,
              icon: Icons.delete_outline,
              onTap: () => deleteAddress(mAddressModel[index]),
            ),
          ],
          child: InkWell(
            onTap: () {
              setState(() {
                selectedAddressIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Radio(
                      value: index,
                      groupValue: selectedAddressIndex,
                      onChanged: (value) {
                        setState(() {
                          selectedAddressIndex = value;
                        });
                      },
                      activeColor: primaryColor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(mAddressModel[index].first_name.validate() + ' ' + mAddressModel[index].last_name.validate(), style: boldFonts(size: 18)),
                        Divider(),
                        Text(
                          mAddressModel[index].address_1,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.fade,
                        ),
                        SizedBox(height: 5),
                        Text(mAddressModel[index].contact),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      shrinkWrap: true,
      itemCount: mAddressModel.length,
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              color: blackColor,
              icon: Icon(Icons.add),
              onPressed: () async {
                var bool = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AddNewAddress()));
                if (bool) {
                  getAddress();
                }
              })
        ],
        title: Text(
          AppLocalizations.of(context).translate('address_manager'),
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: whiteColor,
        leading: IconButton(color: blackColor, icon: Icon(Icons.keyboard_backspace), onPressed: () => {finish(context)}),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                listView.visible(mAddressModel.isNotEmpty),
                SizedBox(height: 10),
                MaterialButton(
                  color: primaryColor,
                  minWidth: double.infinity,
                  textColor: whiteColor,
                  child: Text(AppLocalizations.of(context).translate('choose')),
                  onPressed: () {
                    if (selectedAddressIndex != -1) {
                      Navigator.pop(context, mAddressModel[selectedAddressIndex]);
                    } else {
                      toast(AppLocalizations.of(context).translate('choose_one_address'));
                    }
                  },
                ).visible(mAddressModel.isNotEmpty),
                Container(
                  child: Center(child: Text(AppLocalizations.of(context).translate('tap_to_add_address'))),
                ).visible(mAddressModel.isEmpty).visible(!mIsLoading),
              ],
            ),
          ),
          Center(child: CircularProgressIndicator()).visible(mIsLoading),
        ],
      ),
    );
  }
}
