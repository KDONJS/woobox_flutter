class CreateOrderRequestModel {
  var line_items = List<LineItemsRequest>();
  var shipping = List<BillingShippingRequest>();
  int customer_id;

  CreateOrderRequestModel({this.line_items, this.shipping, this.customer_id});

  factory CreateOrderRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequestModel(
        line_items: json['line_items'],
        shipping: json['shipping'],
        customer_id: json['customer_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['line_items'] = this.line_items;
    data['shipping'] = this.shipping;
    data['customer_id'] = this.customer_id;
    return data;
  }
}

class LineItemsRequest {
  int product_id;
  String quantity;
  int variation_id;

  LineItemsRequest({this.product_id, this.quantity, this.variation_id});

  factory LineItemsRequest.fromJson(Map<String, dynamic> json) {
    return LineItemsRequest(
        product_id: json['product_id'],
        quantity: json['quantity'],
        variation_id: json['variation_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.product_id;
    data['quantity'] = this.quantity;
    data['variation_id'] = this.variation_id;
    return data;
  }
}

class BillingShippingRequest {
  var first_name;
  var last_name;
  var address_1;
  var address_2;
  var city;
  var state;
  var postcode;
  var country;
  var email;
  var phone;

  BillingShippingRequest(
      {this.first_name,
      this.last_name,
      this.address_1,
      this.address_2,
      this.city,
      this.state,
      this.postcode,
      this.country,
      this.email,
      this.phone});

  factory BillingShippingRequest.fromJson(Map<String, dynamic> json) {
    return BillingShippingRequest(
        first_name: json['first_name'],
        last_name: json['last_name'],
        address_1: json['address_1'],
        address_2: json['address_2'],
        city: json['city'],
        state: json['state'],
        postcode: json['postcode'],
        country: json['country'],
        email: json['email'],
        phone: json['phone']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.first_name;
    data['last_name'] = this.last_name;
    data['address_1'] = this.address_1;
    data['address_1'] = this.address_1;
    data['address_2'] = this.address_2;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postcode'] = this.postcode;
    data['country'] = this.country;
    data['email'] = this.email;
    return data;
  }
}
