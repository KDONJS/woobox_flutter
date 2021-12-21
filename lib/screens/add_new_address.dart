import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/AddressModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

class AddNewAddress extends StatefulWidget {
  static String tag = '/AddNewAddress';

  @override
  AddNewAddressState createState() => AddNewAddressState();
}

class AddNewAddressState extends State<AddNewAddress> {
  var mAddressModel = List<AddressModel>();
  var primaryColor;

  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var pinCodeCont = TextEditingController();
  var cityCont = TextEditingController();
  var stateCont = TextEditingController();
  var addressTypeCont = TextEditingController();
  var addressCont = TextEditingController();
  var address2Cont = TextEditingController();
  var phoneNumberCont = TextEditingController();
  var emailCont = TextEditingController();
  var countryCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    primaryColor = await getThemeColor();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    void onSaveClicked() async {
      var pref = await getSharedPref();
      var request = {
        'first_name': firstNameCont.text,
        'last_name': lastNameCont.text,
        'company': '',
        'contact': phoneNumberCont.text,
        'address_1': addressCont.text,
        'address_2': address2Cont.text,
        'city': cityCont.text,
        'state': stateCont.text,
        'country': countryCont.text,
        'postcode': pinCodeCont.text,
      };

      await addAddressApi(request).then((res) {
        hideKeyboard(context);
        Navigator.pop(context, true);
      }).catchError((error) {
        toast(error.toString());
      });

      /*setState(() {
        if (pref.get(STORED_ADDRESSES) != null) {
          dynamic json = jsonDecode(pref.getString(STORED_ADDRESSES));
          Iterable list = json;

          if (json != null && list.length > 0) {
            mAddressModel = list.map((model) => AddressModel.fromJson(model)).toList();
          }
        }

        var addressModel = AddressModel();
        addressModel.first_name = firstNameCont.text;
        addressModel.postcode = pinCodeCont.text;
        addressModel.city = cityCont.text;
        addressModel.state = stateCont.text;
        addressModel.address_1 = addressCont.text;
        addressModel.contact = phoneNumberCont.text;

        mAddressModel.add(addressModel);

        pref.setString(STORED_ADDRESSES, jsonEncode(mAddressModel));
        Navigator.pop(context, true);
      });*/
    }

    getLocation() async {
      var position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var coordinates = Coordinates(position.latitude, position.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      print("${addresses} : ${first.addressLine}");
      setState(() {
        pinCodeCont.text = first.postalCode;
        addressCont.text = first.addressLine;
        cityCont.text = first.locality;
        stateCont.text = first.adminArea;
        countryCont.text = first.countryName;
      });
    }

    Widget useCurrentLocation = Container(
      alignment: Alignment.center,
      child: MaterialButton(
        onPressed: () => {getLocation()},
        child: Row(
          children: <Widget>[Icon(Icons.my_location, color: primaryColor), SizedBox(width: 10), Text('Use Current Location', style: boldFonts(color: primaryColor))],
        ),
      ),
    );

    Widget firstName = TextFormField(
      controller: firstNameCont,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      autofocus: false,
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('first_name'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget lastName = TextFormField(
      controller: lastNameCont,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      autofocus: false,
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('last_name'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget pinCode = TextFormField(
      controller: pinCodeCont,
      keyboardType: TextInputType.number,
      maxLength: 6,
      autofocus: false,
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('pin_code'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget city = TextFormField(
      controller: cityCont,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      textInputAction: TextInputAction.next,
      autofocus: false,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('city'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget state = TextFormField(
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      controller: stateCont,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      autofocus: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('state'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget country = TextFormField(
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      controller: countryCont,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      autofocus: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('country'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget email = TextFormField(
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      controller: emailCont,
      keyboardType: TextInputType.text,
      autofocus: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('Email'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget addressType = TextFormField(
      controller: addressTypeCont,
      keyboardType: TextInputType.text,
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofocus: false,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('address_type'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget address = TextFormField(
      controller: addressCont,
      keyboardType: TextInputType.text,
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      autofocus: false,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('Address'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget address2 = TextFormField(
      controller: address2Cont,
      keyboardType: TextInputType.text,
      onFieldSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
      autofocus: false,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: '${AppLocalizations.of(context).translate('Address')} 2',
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget phoneNumber = TextFormField(
      onFieldSubmitted: (term) {
        phoneNumberCont.clear();
      },
      controller: phoneNumberCont,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      maxLength: 10,
      autofocus: false,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('phone_number'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
    );

    Widget saveButton = MaterialButton(
      height: materialButtonHeight,
      minWidth: double.infinity,
      shape: roundedRectangleBorder(20),
      onPressed: () {
        if (firstNameCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('fname_required'));
        } else if (lastNameCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('lname_required'));
        } else if (phoneNumberCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('phone_number_required'));
        } else if (addressCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('Address_required'));
        } else if (cityCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('city_required'));
        } else if (stateCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('state_required'));
        } else if (countryCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('country_required'));
        } else if (pinCodeCont.text.isEmpty) {
          toast(AppLocalizations.of(context).translate('pin_code_required'));
        } else {
          onSaveClicked();
        }
      },
      color: Colors.white,
      child: Text(AppLocalizations.of(context).translate('save'), style: TextStyle(color: primaryColor, fontSize: 20)),
    );

    Widget body = Wrap(runSpacing: 8, children: <Widget>[
      useCurrentLocation,
      firstName,
      lastName,
      phoneNumber,
      address,
      address2,
      city,
      state,
      country,
      pinCode,
      saveButton,
    ]);

    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('add_new_address')),
      body: Container(child: SingleChildScrollView(child: body), margin: EdgeInsets.all(16)),
    );
  }
}
