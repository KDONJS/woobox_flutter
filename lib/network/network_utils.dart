import 'dart:convert';

import 'package:WooBox/utils/constants.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

bool isSuccessful(status) {
  return status >= 200 && status <= 300;
}

Future buildTokenHeader() async {
  var pref = await getSharedPref();

  var header = {
    "token": "${pref.getString(TOKEN)}",
    "id": "${pref.getInt(USER_ID)}",
    "Content-Type": "application/json",
    //"Accept": "application/json",
  };
  print(jsonEncode(header));
  return header;
}

Future<Response> postRequest(String endPoint, body, {requireToken = false}) async {
  if (!await isNetworkAvailable()) {
    throw noInternetMsg;
  }
  var pref = await getSharedPref();

  print('URL: $mBaseUrl$endPoint');
  print('Request: $body');
  var headers = {'Content-Type': 'application/json'};
  if (requireToken) {
    var header = {
      "token": "${pref.getString(TOKEN)}",
      "id": "${pref.getInt(USER_ID)}",
      //"Accept": "application/json",
    };
    headers.addAll(header);
  }
  print(headers.toString());
  final encoding = Encoding.getByName('utf-8');
  var response = await post('$mBaseUrl$endPoint', body: jsonEncode(body), headers: headers, encoding: encoding);

  print('Status Code: ${response.statusCode}');
  print(jsonDecode(response.body));
  return response;
}

Future<Response> getRequest(String endPoint) async {
  if (!await isNetworkAvailable()) {
    throw noInternetMsg;
  }
  var url = '$mBaseUrl$endPoint';
  print('URL: $url');

  var header = await buildTokenHeader();
  var response = await get(url, headers: header);

  print('Status Code: ${response.statusCode}');
  print(jsonDecode(response.body));
  return response;
}

Future handleResponse(Response response) async {
  if (!await isNetworkAvailable()) {
    throw noInternetMsg;
  }
  String body = response.body;
  if (isSuccessful(response.statusCode)) {
    return jsonDecode(body);
  } else {
    if (await isJsonValid(body)) {
      throw jsonDecode(body)[msg];
    } else {
      throw errorMsg;
    }
  }
}

extension json on Map {
  toJson() {
    return jsonEncode(this);
  }
}

extension on String {
  toJson() {
    return jsonEncode(this);
  }
}

Future<bool> isJsonValid(json) async {
  try {
    var f = jsonDecode(json) as Map<String, dynamic>;
    return true;
  } catch (e) {
    print(e.toString());
  }
  return false;
}
