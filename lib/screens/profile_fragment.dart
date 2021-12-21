import 'dart:convert';
import 'dart:io';

import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/colors.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:WooBox/utils/shared_pref.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';

class ProfileFragment extends StatefulWidget {
  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  SharedPreferences pref;
  var primaryColor;
  var isSocialLogin = false;
  File mSelectedImage;

  String fName;
  String lName;
  String email;
  String avatar = '';

  var fNameCont = TextEditingController();
  var lNameCont = TextEditingController();
  var emailCont = TextEditingController();

  setPref() async {
    primaryColor = await getThemeColor();
    pref = await getSharedPref();
    setState(() {
      fName = pref.getString(FIRST_NAME);
      lName = pref.getString(LAST_NAME);
      email = pref.getString(USER_EMAIL);

      fNameCont.text = fName;
      lNameCont.text = lName;
      emailCont.text = email;
      avatar = pref.get(PROFILE_IMAGE) != null ? pref.getString(PROFILE_IMAGE) : pref.getString(AVATAR);
      isSocialLogin = pref.getBool(IS_SOCIAL_LOGIN) == null ? true : pref.getBool(IS_SOCIAL_LOGIN);
    });
  }

  @override
  void initState() {
    super.initState();
    setPref();
  }

  @override
  Widget build(BuildContext context) {
    saveUser() async {
      hideKeyboard(context);
      var request = {
        'email': emailCont.text,
        'first_name': fNameCont.text,
        'last_name': lNameCont.text,
      };
      var id = pref.getInt(USER_ID);

      createCustomer(id, request).then((res) {
        if (!mounted) return;
        pref.setString(FIRST_NAME, fNameCont.text);
        pref.setString(LAST_NAME, lNameCont.text);
        pref.setString(USER_EMAIL, emailCont.text);
        toast(AppLocalizations.of(context).translate('profile_saved_success'));
      }).catchError((error) {
        toast(error.toString());
      });
    }

    pickImage() async {
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        mSelectedImage = image;
      });

      if (mSelectedImage != null) {
        ConfirmAction res = await showConfirmDialogs(context, 'Are you sure want to upload image?', 'Yes', 'No');

        if (res == ConfirmAction.ACCEPT) {
          var base64Image = base64Encode(mSelectedImage.readAsBytesSync());
          var request = {'base64_img': base64Image};
          await saveProfileImage(request).then((res) async {
            if (!mounted) return;
          }).catchError((error) {
            toast(error.toString());
          });
        }
      }
    }

    Widget profileImage = ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: mSelectedImage == null
          ? avatar.isEmpty
              ? SizedBox()
              : Image.network(
                  avatar,
                  width: 120,
                  height: 120,
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return getLoadingProgress(loadingProgress);
                  },
                )
          : Image.file(
              mSelectedImage,
              width: 120,
              height: 120,
              fit: BoxFit.fill,
            ),
    ).onTap(() => pickImage());

    Widget fName = TextField(
      autofocus: false,
      controller: fNameCont,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: editTextBackgroundColor,
        focusColor: editTextFocusedColor,
        hintText: AppLocalizations.of(context).translate('first_name'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
      onSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
    );

    Widget lName = TextField(
      autofocus: false,
      controller: lNameCont,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: editTextBackgroundColor,
        focusColor: editTextFocusedColor,
        hintText: AppLocalizations.of(context).translate('last_name'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
      onSubmitted: (term) {
        FocusScope.of(context).nextFocus();
      },
    );

    Widget email = TextField(
      controller: emailCont,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: editTextBackgroundColor,
        focusColor: editTextFocusedColor,
        hintText: AppLocalizations.of(context).translate('Email'),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: textFiledBorderStyle,
      ),
      onSubmitted: (term) {
        hideKeyboard(context);
      },
    );

    Widget saveButton = MaterialButton(
      height: materialButtonHeight,
      minWidth: double.infinity,
      onPressed: () => {saveUser()},
      shape: roundedRectangleBorder(20),
      color: primaryColor,
      child: Text(AppLocalizations.of(context).translate('save_profile'), style: TextStyle(fontSize: 18)),
      textColor: Colors.white,
    );

    Widget changePasswordButton = MaterialButton(
      height: materialButtonHeight,
      minWidth: double.infinity,
      elevation: 4,
      onPressed: () => {openChangePasswordDialog(context)},
      shape: roundedRectangleBorder(20),
      color: Colors.white,
      child: Text(AppLocalizations.of(context).translate('change_password'), style: TextStyle(fontSize: 18)),
      textColor: primaryColor,
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              profileImage,
              SizedBox(height: 30),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(child: fName),
                    SizedBox(width: 10),
                    Expanded(child: lName),
                  ],
                ),
              ),
              SizedBox(height: 10),
              email,
              SizedBox(height: 30),
              saveButton,
              SizedBox(height: 10),
              isSocialLogin ? changePasswordButton : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
