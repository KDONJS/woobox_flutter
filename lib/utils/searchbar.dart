import 'package:WooBox/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  static String tag = '/SearchBar';

  final void Function(String) onTextChange;
  final String hintText;

  SearchBar({this.onTextChange, this.hintText});

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  var primaryColor;

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
    return Container(
        height: 70,
        padding: EdgeInsets.all(8),
        child: TextField(
            autofocus: true,
            onChanged: widget.onTextChange,
            decoration: InputDecoration(
                fillColor: Colors.black.withOpacity(0.1),
                filled: true,
                prefixIcon: Icon(Icons.search, color: primaryColor),
                hintText: widget.hintText,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero)));
  }
}
