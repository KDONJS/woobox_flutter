class OrderDataModel {
  Billing billing;
  String cart_hash;
  String cart_tax;
  String created_via;
  String currency;
  int customer_id;
  String customer_ip_address;
  String customer_note;
  String customer_user_agent;
  String date_completed;
  String date_completed_gmt;
  String date_created;
  String date_created_gmt;
  String date_modified;
  String date_modified_gmt;
  String date_paid;
  String date_paid_gmt;
  String discount_tax;
  String discount_total;
  int id;
  List<LineItem> line_items;
  String number;
  String order_key;
  int parent_id;
  String payment_method;
  String payment_method_title;
  bool prices_include_tax;
  Shipping shipping;
  String shipping_tax;
  String shipping_total;
  String status;
  String total;
  String total_tax;
  String transaction_id;
  String version;

  OrderDataModel(
      {this.billing,
      this.cart_hash,
      this.cart_tax,
      this.created_via,
      this.currency,
      this.customer_id,
      this.customer_ip_address,
      this.customer_note,
      this.customer_user_agent,
      this.date_completed,
      this.date_completed_gmt,
      this.date_created,
      this.date_created_gmt,
      this.date_modified,
      this.date_modified_gmt,
      this.date_paid,
      this.date_paid_gmt,
      this.discount_tax,
      this.discount_total,
      this.id,
      this.line_items,
      this.number,
      this.order_key,
      this.parent_id,
      this.payment_method,
      this.payment_method_title,
      this.prices_include_tax,
      this.shipping,
      this.shipping_tax,
      this.shipping_total,
      this.status,
      this.total,
      this.total_tax,
      this.transaction_id,
      this.version});

  factory OrderDataModel.fromJson(Map<String, dynamic> json) {
    return OrderDataModel(
      billing:
          json['billing'] != null ? Billing.fromJson(json['billing']) : null,
      cart_hash: json['cart_hash'],
      cart_tax: json['cart_tax'],
      created_via: json['created_via'],
      currency: json['currency'],
      customer_id: json['customer_id'],
      customer_ip_address: json['customer_ip_address'],
      customer_note: json['customer_note'],
      customer_user_agent: json['customer_user_agent'],
      date_completed: json['date_completed'],
      date_completed_gmt: json['date_completed_gmt'],
      date_created: json['date_created'],
      date_created_gmt: json['date_created_gmt'],
      date_modified: json['date_modified'],
      date_modified_gmt: json['date_modified_gmt'],
      date_paid: json['date_paid'],
      date_paid_gmt: json['date_paid_gmt'],
      discount_tax: json['discount_tax'],
      discount_total: json['discount_total'],
      id: json['id'],
      line_items: json['line_items'] != null
          ? (json['line_items'] as List)
              .map((i) => LineItem.fromJson(i))
              .toList()
          : null,
      number: json['number'],
      order_key: json['order_key'],
      parent_id: json['parent_id'],
      payment_method: json['payment_method'],
      payment_method_title: json['payment_method_title'],
      prices_include_tax: json['prices_include_tax'],
      shipping:
          json['shipping'] != null ? Shipping.fromJson(json['shipping']) : null,
      shipping_tax: json['shipping_tax'],
      shipping_total: json['shipping_total'],
      status: json['status'],
      total: json['total'],
      total_tax: json['total_tax'],
      transaction_id: json['transaction_id'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cart_hash'] = this.cart_hash;
    data['cart_tax'] = this.cart_tax;
    data['created_via'] = this.created_via;
    data['currency'] = this.currency;
    data['customer_id'] = this.customer_id;
    data['customer_ip_address'] = this.customer_ip_address;
    data['customer_note'] = this.customer_note;
    data['customer_user_agent'] = this.customer_user_agent;
    data['date_completed'] = this.date_completed;
    data['date_completed_gmt'] = this.date_completed_gmt;
    data['date_created'] = this.date_created;
    data['date_created_gmt'] = this.date_created_gmt;
    data['date_modified'] = this.date_modified;
    data['date_modified_gmt'] = this.date_modified_gmt;
    data['date_paid'] = this.date_paid;
    data['date_paid_gmt'] = this.date_paid_gmt;
    data['discount_tax'] = this.discount_tax;
    data['discount_total'] = this.discount_total;
    data['id'] = this.id;
    data['number'] = this.number;
    data['order_key'] = this.order_key;
    data['parent_id'] = this.parent_id;
    data['payment_method'] = this.payment_method;
    data['payment_method_title'] = this.payment_method_title;
    data['prices_include_tax'] = this.prices_include_tax;
    data['shipping_tax'] = this.shipping_tax;
    data['shipping_total'] = this.shipping_total;
    data['status'] = this.status;
    data['total'] = this.total;
    data['total_tax'] = this.total_tax;
    data['transaction_id'] = this.transaction_id;
    data['version'] = this.version;
    if (this.billing != null) {
      data['billing'] = this.billing.toJson();
    }
    if (this.line_items != null) {
      data['line_items'] = this.line_items.map((v) => v.toJson()).toList();
    }
    if (this.shipping != null) {
      data['shipping'] = this.shipping.toJson();
    }
    return data;
  }
}

class Billing {
  String address_1;
  String address_2;
  String city;
  String company;
  String country;
  String email;
  String first_name;
  String last_name;
  String phone;
  String postcode;
  String state;

  Billing(
      {this.address_1,
      this.address_2,
      this.city,
      this.company,
      this.country,
      this.email,
      this.first_name,
      this.last_name,
      this.phone,
      this.postcode,
      this.state});

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      address_1: json['address_1'],
      address_2: json['address_2'],
      city: json['city'],
      company: json['company'],
      country: json['country'],
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      phone: json['phone'],
      postcode: json['postcode'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_1'] = this.address_1;
    data['address_2'] = this.address_2;
    data['city'] = this.city;
    data['company'] = this.company;
    data['country'] = this.country;
    data['email'] = this.email;
    data['first_name'] = this.first_name;
    data['last_name'] = this.last_name;
    data['phone'] = this.phone;
    data['postcode'] = this.postcode;
    data['state'] = this.state;
    return data;
  }
}

class LineItem {
  int id;
  List<MetaData> meta_data;
  String name;
  int price;
  int product_id;
  int quantity;
  String sku;
  String subtotal;
  String subtotal_tax;
  String tax_class;
  String total;
  String total_tax;
  int variation_id;

  LineItem(
      {this.id,
      this.meta_data,
      this.name,
      this.price,
      this.product_id,
      this.quantity,
      this.sku,
      this.subtotal,
      this.subtotal_tax,
      this.tax_class,
      this.total,
      this.total_tax,
      this.variation_id});

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      id: json['id'],
      meta_data: json['meta_data'] != null
          ? (json['meta_data'] as List)
              .map((i) => MetaData.fromJson(i))
              .toList()
          : null,
      name: json['name'],
      price: json['price'],
      product_id: json['product_id'],
      quantity: json['quantity'],
      sku: json['sku'],
      subtotal: json['subtotal'],
      subtotal_tax: json['subtotal_tax'],
      tax_class: json['tax_class'],
      total: json['total'],
      total_tax: json['total_tax'],
      variation_id: json['variation_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['product_id'] = this.product_id;
    data['quantity'] = this.quantity;
    data['sku'] = this.sku;
    data['subtotal'] = this.subtotal;
    data['subtotal_tax'] = this.subtotal_tax;
    data['tax_class'] = this.tax_class;
    data['total'] = this.total;
    data['total_tax'] = this.total_tax;
    data['variation_id'] = this.variation_id;
    if (this.meta_data != null) {
      data['meta_data'] = this.meta_data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MetaData {
  int id;
  String key;
  String value;

  MetaData({this.id, this.key, this.value});

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      id: json['id'],
      key: json['key'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}

class Shipping {
  String address_1;
  String address_2;
  String city;
  String company;
  String country;
  String first_name;
  String last_name;
  String postcode;
  String state;

  Shipping(
      {this.address_1,
      this.address_2,
      this.city,
      this.company,
      this.country,
      this.first_name,
      this.last_name,
      this.postcode,
      this.state});

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      address_1: json['address_1'],
      address_2: json['address_2'],
      city: json['city'],
      company: json['company'],
      country: json['country'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      postcode: json['postcode'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_1'] = this.address_1;
    data['address_2'] = this.address_2;
    data['city'] = this.city;
    data['company'] = this.company;
    data['country'] = this.country;
    data['first_name'] = this.first_name;
    data['last_name'] = this.last_name;
    data['postcode'] = this.postcode;
    data['state'] = this.state;
    return data;
  }
}
