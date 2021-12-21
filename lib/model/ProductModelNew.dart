class ProductModelNew {
  String average_rating;
  String backorders;
  String brand;
  String catalog_visibility;
  List<int> categories;
  String color;
  DateCreated date_created;
  DateModified date_modified;
  String description='';
  String dimensions;
  bool featured;
  String full;
  List<String> gallery;
  String get_purchase_note;
  String height='';
  String length='';
  bool manage_stock;
  String name='';
  int num_pages;
  int parent_id;
  String permalink;
  String price='';
  int pro_id;
  String regular_price='';
  int review_count;
  bool reviews_allowed;
  String sale_price;
  int shipping_class_id;
  String short_description;
  String size;
  String sku;
  String slug;
  bool sold_individually;
  int srno;
  String status;
  int stock_quantity;
  String stock_status;
  String tax_class;
  String tax_status;
  String thumbnail;
  String type;
  bool virtual;
  String weight;
  String width='';

  ProductModelNew(
      {this.average_rating,
      this.backorders,
      this.brand,
      this.catalog_visibility,
      this.categories,
      this.color,
      this.date_created,
      this.date_modified,
      this.description,
      this.dimensions,
      this.featured,
      this.full,
      this.gallery,
      this.get_purchase_note,
      this.height,
      this.length,
      this.manage_stock,
      this.name,
      this.num_pages,
      this.parent_id,
      this.permalink,
      this.price,
      this.pro_id,
      this.regular_price,
      this.review_count,
      this.reviews_allowed,
      this.sale_price,
      this.shipping_class_id,
      this.short_description,
      this.size,
      this.sku,
      this.slug,
      this.sold_individually,
      this.srno,
      this.status,
      this.stock_quantity,
      this.stock_status,
      this.tax_class,
      this.tax_status,
      this.thumbnail,
      this.type,
      this.virtual,
      this.weight,
      this.width});

  factory ProductModelNew.fromJson(Map<String, dynamic> json) {
    return ProductModelNew(
      average_rating: json['average_rating'],
      backorders: json['backorders'],
      brand: json['brand'],
      catalog_visibility: json['catalog_visibility'],
      categories: json['categories'] != null
          ? new List<int>.from(json['categories'])
          : null,
      color: json['color'],
      date_created: json['date_created'] != null
          ? DateCreated.fromJson(json['date_created'])
          : null,
      date_modified: json['date_modified'] != null
          ? DateModified.fromJson(json['date_modified'])
          : null,
      description: json['description'],
      dimensions: json['dimensions'],
      featured: json['featured'],
      full: json['full'],
      gallery: json['gallery'] != null
          ? new List<String>.from(json['gallery'])
          : null,
      get_purchase_note: json['get_purchase_note'],
      height: json['height'],
      length: json['length'],
      manage_stock: json['manage_stock'],
      name: json['name'],
      num_pages: json['num_pages'],
      parent_id: json['parent_id'],
      permalink: json['permalink'],
      price: json['price'],
      pro_id: json['pro_id'],
      regular_price: json['regular_price'],
      review_count: json['review_count'],
      reviews_allowed: json['reviews_allowed'],
      sale_price: json['sale_price'],
      shipping_class_id: json['shipping_class_id'],
      short_description: json['short_description'],
      size: json['size'],
      sku: json['sku'],
      slug: json['slug'],
      sold_individually: json['sold_individually'],
      srno: json['srno'],
      status: json['status'],
      stock_quantity: json['stock_quantity'],
      stock_status: json['stock_status'],
      tax_class: json['tax_class'],
      tax_status: json['tax_status'],
      thumbnail: json['thumbnail'],
      type: json['type'],
      virtual: json['virtual'],
      weight: json['weight'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['average_rating'] = this.average_rating;
    data['backorders'] = this.backorders;
    data['brand'] = this.brand;
    data['catalog_visibility'] = this.catalog_visibility;
    data['color'] = this.color;
    data['description'] = this.description;
    data['dimensions'] = this.dimensions;
    data['featured'] = this.featured;
    data['full'] = this.full;
    data['get_purchase_note'] = this.get_purchase_note;
    data['height'] = this.height;
    data['length'] = this.length;
    data['manage_stock'] = this.manage_stock;
    data['name'] = this.name;
    data['num_pages'] = this.num_pages;
    data['parent_id'] = this.parent_id;
    data['permalink'] = this.permalink;
    data['price'] = this.price;
    data['pro_id'] = this.pro_id;
    data['regular_price'] = this.regular_price;
    data['review_count'] = this.review_count;
    data['reviews_allowed'] = this.reviews_allowed;
    data['sale_price'] = this.sale_price;
    data['shipping_class_id'] = this.shipping_class_id;
    data['short_description'] = this.short_description;
    data['size'] = this.size;
    data['sku'] = this.sku;
    data['slug'] = this.slug;
    data['sold_individually'] = this.sold_individually;
    data['srno'] = this.srno;
    data['status'] = this.status;
    data['stock_quantity'] = this.stock_quantity;
    data['stock_status'] = this.stock_status;
    data['tax_class'] = this.tax_class;
    data['tax_status'] = this.tax_status;
    data['thumbnail'] = this.thumbnail;
    data['type'] = this.type;
    data['virtual'] = this.virtual;
    data['weight'] = this.weight;
    data['width'] = this.width;
    if (this.categories != null) {
      data['categories'] = this.categories;
    }
    if (this.date_created != null) {
      data['date_created'] = this.date_created.toJson();
    }
    if (this.date_modified != null) {
      data['date_modified'] = this.date_modified.toJson();
    }
    if (this.gallery != null) {
      data['gallery'] = this.gallery;
    }
    return data;
  }
}

class DateModified {
  String date;
  String timezone;
  int timezone_type;

  DateModified({this.date, this.timezone, this.timezone_type});

  factory DateModified.fromJson(Map<String, dynamic> json) {
    return DateModified(
      date: json['date'],
      timezone: json['timezone'],
      timezone_type: json['timezone_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['timezone'] = this.timezone;
    data['timezone_type'] = this.timezone_type;
    return data;
  }
}

class DateCreated {
  String date;
  String timezone;
  int timezone_type;

  DateCreated({this.date, this.timezone, this.timezone_type});

  factory DateCreated.fromJson(Map<String, dynamic> json) {
    return DateCreated(
      date: json['date'],
      timezone: json['timezone'],
      timezone_type: json['timezone_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['timezone'] = this.timezone;
    data['timezone_type'] = this.timezone_type;
    return data;
  }
}
