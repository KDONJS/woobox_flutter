import 'dart:convert';

import 'package:WooBox/model/LoginResponse.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'network_utils.dart';
import 'woo_commerce_api.dart';

Future createCustomer(id, request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/customers/$id', request));
}

Future getCustomer(id) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/customers/$id'));
}

Future getSliderImages() async {
  return handleResponse(await WooCommerceAPI().getAsync('woobox-api/api/v1/slider/get-slider/'));
}

Future getCategories() async {
  return handleResponse(await WooCommerceAPI().getAsync('woobox-api/api/v1/woocommerce/get-category'));
}

Future getProducts(page) async {
  return handleResponse(await WooCommerceAPI().getAsync('woobox-api/api/v1/woocommerce/get-product?&page=$page'));
}

Future getSingleProducts(productId) async {
  return handleResponse(await WooCommerceAPI().postAsync('woobox-api/api/v1/woocommerce/get-single-product', {'pro_id': productId}));
}

Future getFeaturedProducts() async {
  return handleResponse(await WooCommerceAPI().getAsync('woobox-api/api/v1/woocommerce/get-featured-product'));
}

Future getMyOffers() async {
  return handleResponse(await WooCommerceAPI().getAsync('woobox-api/api/v1/woocommerce/get-offer-product'));
}

Future getOrders({page = 1}) async {
  var pref = await getSharedPref();

  var customer = pref.getInt(USER_ID).toString();

  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/orders?customer=$customer&page=$page'));
}

Future getSubCategories(int cat_id) async {
  return handleResponse(await WooCommerceAPI().postAsync('woobox-api/api/v1/woocommerce/get-sub-category', {'cat_id': cat_id}, requireToken: true));
}

Future getProductReviews(mProductId) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v1/products/$mProductId/reviews'));
}

Future createOrderApi(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/orders', request));
}

Future postReview(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/products/reviews', request));
}

Future changePassword(request) async {
  var pref = await getSharedPref();
  return handleResponse(await WooCommerceAPI().postAsync('wp/v2/users/${pref.getInt(USER_ID)}', request));
}

Future getActivePaymentGatewaysApi() async {
  return handleResponse(await WooCommerceAPI().getAsync('woobox-api/api/v1/payment/get-active-payment-gateway'));
}

///

Future<LoginResponse> login(request) async {
  var response = await postRequest('jwt-auth/v1/token', request);

  dynamic body = jsonDecode(response.body);
  if (isSuccessful(response.statusCode)) {
    LoginResponse response = LoginResponse.fromJson(body);
    return response;
  } else {
    if (await isJsonValid(response.body)) {
      throw parseHtmlString(jsonDecode(response.body)[msg]);
    } else {
      throw errorMsg;
    }
  }
}

Future getCheckOutUrl(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/woocommerce/get-checkout-url', request, requireToken: true));
}

Future getBlogApi(page) async {
  return handleResponse(await getRequest('woobox-api/api/v1/blog/get-blog?page=$page'));
}

Future socialLoginApi(request) async {
  print(jsonEncode(request));
  return handleResponse(await postRequest('woobox-api/api/v1/customer/social_login', request));
}

Future getDashboardApi() async {
  if (await getBool(IS_LOGGED_IN)) {
    var request = {'user_id': getInt(USER_ID)};
    return handleResponse(await postRequest('woobox-api/api/v1/woocommerce/get-dashboard', request, requireToken: true));
  } else {
    return handleResponse(await postRequest('woobox-api/api/v1/woocommerce/get-dashboard', {}, requireToken: false));
  }
}

Future deleteReview(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/woocommerce/delete-review/', request, requireToken: true));
}

Future getCartList() async {
  return handleResponse(await getRequest('woobox-api/api/v1/cart/get-cart/'));
}

Future getWishList() async {
  return handleResponse(await getRequest('woobox-api/api/v1/wishlist/get-wishlist/'));
}

Future clearCartItems() async {
  return handleResponse(await getRequest('woobox-api/api/v1/cart/clear-cart/'));
}

Future filterProducts(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/woocommerce/get-product', request));
}

Future getProductsAttributes() async {
  return handleResponse(await getRequest('woobox-api/api/v1/woocommerce/get-product-attribute/'));
}

Future searchProduct(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/woocommerce/get-search-product', request));
}

Future addWishList(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/wishlist/add-wishlist/', request, requireToken: true));
}

Future removeWishList(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/wishlist/delete-wishlist/', request, requireToken: true));
}

Future addToCart(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/cart/add-cart/', request, requireToken: true));
}

Future removeCartItem(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/cart/delete-cart/', request, requireToken: true));
}

Future updateCartItem(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/cart/update-cart/', request, requireToken: true));
}

Future addAddressApi(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/customer/add-address/', request, requireToken: true));
}

Future deleteAddressApi(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/customer/delete-address/', request, requireToken: true));
}

Future getAddressApi() async {
  return handleResponse(await getRequest('woobox-api/api/v1/customer/get-address'));
}

Future saveProfileImage(request) async {
  return handleResponse(await postRequest('woobox-api/api/v1/customer/save-profile-image', request, requireToken: true));
}
