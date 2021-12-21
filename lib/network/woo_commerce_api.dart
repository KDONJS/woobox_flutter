import 'dart:async';
import "dart:collection";
import 'dart:convert';
import "dart:core";
import 'dart:io';
import "dart:math";

import 'package:WooBox/utils/constants.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/query_string.dart';

class WooCommerceAPI {
  String url;
  String consumerKey;
  String consumerSecret;
  bool isHttps;

  WooCommerceAPI() {
    this.url = mBaseUrl;
    this.consumerKey = mConsumerKey;
    this.consumerSecret = mConsumerSecret;

    if (this.url.startsWith("https")) {
      this.isHttps = true;
    } else {
      this.isHttps = false;
    }
  }

  _getOAuthURL(String requestMethod, String endpoint) {
    var consumerKey = this.consumerKey;
    var consumerSecret = this.consumerSecret;

    var token = mToken;
    var tokenSecret = mTokenSecret;
    var url = this.url + endpoint;
    var containsQueryParams = url.contains("?");
    //print(url);

    // If website is HTTPS based, no need for OAuth, just return the URL with CS and CK as query params
    /*if (this.isHttps == true) {
      return url +
          (containsQueryParams == true
              ? "&consumer_key=" +
                  this.consumerKey +
                  "&consumer_secret=" +
                  this.consumerSecret
              : "?consumer_key=" +
                  this.consumerKey +
                  "&consumer_secret=" +
                  this.consumerSecret);
    }*/

    var rand = new Random();
    var codeUnits = new List.generate(10, (index) {
      return rand.nextInt(26) + 97;
    });

    var nonce = new String.fromCharCodes(codeUnits);
    int timestamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;

    //print(timestamp);
    //print(nonce);

    var method = requestMethod;
    var path = url.split("?")[0];
    var parameters =
        "oauth_consumer_key=" + consumerKey + "&oauth_nonce=" + nonce + "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=" + timestamp.toString() + "&oauth_token=" + token + "&oauth_version=1.0&";

    if (containsQueryParams == true) {
      parameters = parameters + url.split("?")[1];
    } else {
      parameters = parameters.substring(0, parameters.length - 1);
    }

    Map<dynamic, dynamic> params = QueryString.parse(parameters);
    Map<dynamic, dynamic> treeMap = new SplayTreeMap<dynamic, dynamic>();
    treeMap.addAll(params);

    String parameterString = "";

    for (var key in treeMap.keys) {
      parameterString = parameterString + Uri.encodeQueryComponent(key) + "=" + treeMap[key] + "&";
    }

    parameterString = parameterString.substring(0, parameterString.length - 1);

    var baseString = method + "&" + Uri.encodeQueryComponent(containsQueryParams == true ? url.split("?")[0] : url) + "&" + Uri.encodeQueryComponent(parameterString);

    //print(baseString);

    var signingKey = consumerSecret + "&" + tokenSecret;
    //print(signingKey);
    //print(UTF8.encode(signingKey));
    var hmacSha1 = new crypto.Hmac(crypto.sha1, utf8.encode(signingKey)); // HMAC-SHA1
    var signature = hmacSha1.convert(utf8.encode(baseString));

    //print(signature);

    var finalSignature = base64Encode(signature.bytes);
    //print(finalSignature);

    var requestUrl = "";

    if (containsQueryParams == true) {
      //print(url.split("?")[0] + "?" + parameterString + "&oauth_signature=" + Uri.encodeQueryComponent(finalSignature));
      requestUrl = url.split("?")[0] + "?" + parameterString + "&oauth_signature=" + Uri.encodeQueryComponent(finalSignature);
    } else {
      //print(url + "?" +  parameterString + "&oauth_signature=" + Uri.encodeQueryComponent(finalSignature));
      requestUrl = url + "?" + parameterString + "&oauth_signature=" + Uri.encodeQueryComponent(finalSignature);
    }

    return requestUrl;
  }

  Future<http.Response> getAsync(String endPoint) async {
    var url = this._getOAuthURL("GET", endPoint);

    print(url);
    final response = await http.get(url);
    print('${response.statusCode} $url');
    print(jsonDecode(response.body));

    return response;
  }

  Future<http.Response> postAsync(String endPoint, Map data, {requireToken = false}) async {
    var url = this._getOAuthURL("POST", endPoint);
    print(url);

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      HttpHeaders.cacheControlHeader: 'no-cache',
    };
    if (requireToken) {
      SharedPreferences pref = await getSharedPref();
      var header = {"token": "${pref.getString(TOKEN)}", "id": "${pref.getInt(USER_ID)}"};
      headers.addAll(header);
    }
    print(jsonEncode(headers));
    print(jsonEncode(data));

    var client = new http.Client();
    var response = await client.post(url, body: jsonEncode(data), headers: headers);

    print(response.statusCode);
    print(jsonDecode(response.body));
    return response;

    //TODO do not delete this
    /*var request = new http.Request('POST', Uri.parse(url));
    request.headers[HttpHeaders.contentTypeHeader] =
    'application/json; charset=utf-8';
    request.headers[HttpHeaders.cacheControlHeader] = "no-cache";
    request.body = json.encode(data);
    
    var response =
        await client.send(request).then((res) => res.stream.bytesToString());
    var dataResponse = await json.decode(response);
    return dataResponse;*/
  }
}
