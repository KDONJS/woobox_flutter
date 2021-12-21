import 'package:WooBox/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import 'constants.dart';

Future<bool> isLoggedIn() async {
  return await getBool(IS_LOGGED_IN) ?? false;
}

Future getThemeColor() async {
  try {
    String color = await getString(THEME_COLOR);
    print('color $color');
    if (color == null || color.isEmpty) {
      return primaryColor;
    } else {
      return getColorFromHex(color);
    }
  } catch (e) {
    return primaryColor;
  }
}
