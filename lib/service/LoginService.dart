import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

class LoginService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/plus.me',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ]);

  Future<AuthCredential> getGoogleAuthCredential() async {
    GoogleSignInAccount googleAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication = await googleAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleAuthentication.idToken,
      accessToken: googleAuthentication.accessToken,
    );
    return credential;
  }

  Future<Map> getGoogleSignInData() async {
    var req = {};
    AuthCredential credential = await getGoogleAuthCredential();
    AuthResult authResult = await _auth.signInWithCredential(credential);

    var fullName = authResult.user.displayName.split(' ');
    var firstName = authResult.user.displayName;
    var lastName = authResult.user.displayName;

    if (fullName.length >= 2) {
      firstName = fullName[0].trim();
      lastName = fullName[1].trim();
    } else {
      firstName = authResult.user.displayName;
      lastName = '';
    }
    String token = await authResult.user.getIdToken().then((value) => value.token);

    req = {
      'email': authResult.user.email,
      'firstName': firstName,
      'lastName': lastName,
      'photoURL': authResult.user.photoUrl,
      'accessToken': token,
      'loginType': 'google',
    };
    return req;
  }

  Future signOut() async {
    try {
      _googleSignIn.signOut();
      return await _auth.signOut();
    } catch (e) {
      print(e.message);
      throw Exception('Something went horribly wrong, please try again later!');
    }
  }

  Future<Map> getFacebookSignInData() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final graphResponse = await get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${result.accessToken.token}');
        final profile = jsonDecode(graphResponse.body);
        return {
          'email': profile['email'],
          'firstName': profile['first_name'],
          'lastName': profile['last_name'],
          'photoURL': profile['picture']['data']['url'],
          'accessToken': result.accessToken.token,
          'loginType': 'facebook'
        };
        break;
      case FacebookLoginStatus.cancelledByUser:
        throw 'Cancelled by user';
        break;
      case FacebookLoginStatus.error:
        throw result.errorMessage;
        break;
    }
    return {};
  }
}
