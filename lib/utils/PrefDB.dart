import 'package:WooBox/model/WishListModel.dart';

Future<List<WishListModel>> getWishListFromPref(res) async {
  Iterable data = res;
  return data.map((model) => WishListModel.fromJson(model)).toList();
}
