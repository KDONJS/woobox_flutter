import 'package:WooBox/app_localizations.dart';
import 'package:WooBox/model/BlogModel.dart';
import 'package:WooBox/network/rest_apis.dart';
import 'package:WooBox/utils/app_widgets.dart';
import 'package:WooBox/utils/common.dart';
import 'package:WooBox/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';

class BlogScreen extends StatefulWidget {
  static String tag = '/BlogScreen';

  @override
  BlogScreenState createState() => BlogScreenState();
}

class BlogScreenState extends State<BlogScreen> {
  var page = 1;
  var mBlogModel = List<BlogModel>();
  var scrollController = new ScrollController();
  bool isLastPage = false;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getBlog(page);
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLastPage) {
      page++;
      getBlog(page);
    }
  }

  getBlog(page) async {
    getBlogApi(page).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable youMayLike = res;
        mBlogModel = youMayLike.map((model) => BlogModel.fromJson(model)).toList();
        isLastPage = false;
      });
    }).catchError((error) {
      isLastPage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = ListView.builder(
      shrinkWrap: true,
      itemCount: mBlogModel.length,
      itemBuilder: (_, index) {
        return InkWell(
          onTap: () => BlogDetail(mBlogData: mBlogModel[index]).launch(context),
          child: Card(
            elevation: 1,
            shape: roundedRectangleBorder(16),
            margin: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                    borderRadius: new BorderRadius.circular(16),
                    child: Hero(
                      tag: mBlogModel[index].title.validate(),
                      child: Image.network(
                        mBlogModel[index].image.validate(),
                        fit: BoxFit.cover,
                        loadingBuilder: ((context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return getLoadingProgress(loadingProgress);
                        }),
                      ),
                      transitionOnUserGestures: true,
                    )),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(mBlogModel[index].title.validate(), style: boldFonts(size: 24)),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(mBlogModel[index].publish_date.validate(), style: TextStyle(color: textSecondaryColor)),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: getAppBar(context, AppLocalizations.of(context).translate('blogs')),
      body: mBlogModel.isEmpty ? Center(child: CircularProgressIndicator()) : body,
    );
  }
}

class BlogDetail extends StatefulWidget {
  static String tag = '/BlogDetail';

  final BlogModel mBlogData;

  BlogDetail({Key key, @required this.mBlogData}) : super(key: key);

  @override
  BlogDetailState createState() => BlogDetailState();
}

class BlogDetailState extends State<BlogDetail> {
  @override
  Widget build(BuildContext context) {
    final blog = widget.mBlogData;

    return Scaffold(
      appBar: getAppBar(context, blog.title.validate()),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: blog.title.validate(),
                child: Image.network(
                  blog.image.validate(),
                  fit: BoxFit.cover,
                ),
                transitionOnUserGestures: true,
              ),
              SizedBox(height: 10),
              Text(blog.title.validate(), style: boldFonts(size: 24)).paddingLeft(16),
              SizedBox(height: 5),
              Text(blog.publish_date.validate(), style: TextStyle(color: textSecondaryColor)).paddingLeft(16),
              SizedBox(height: 10),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                child: Text(parseHtmlString(blog.description.validate()), style: TextStyle(color: textSecondaryColor, fontSize: 20), textAlign: TextAlign.justify),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
