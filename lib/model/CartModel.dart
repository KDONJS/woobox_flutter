class CartModel {
    String cart_id;
    String created_at;
    String full;
    List<String> gallery;
    String name;
    String price;
    int pro_id;
    String quantity;
    String regular_price;
    String sale_price;
    String sku;
    int stock_quantity;
    String stock_status;
    String thumbnail;

    CartModel({this.cart_id, this.created_at, this.full, this.gallery, this.name, this.price, this.pro_id, this.quantity, this.regular_price, this.sale_price, this.sku, this.stock_quantity, this.stock_status, this.thumbnail});

    factory CartModel.fromJson(Map<String, dynamic> json) {
        return CartModel(
            cart_id: json['cart_id'],
            created_at: json['created_at'],
            full: json['full'],
            gallery: json['gallery'] != null ? new List<String>.from(json['gallery']) : null,
            name: json['name'],
            price: json['price'],
            pro_id: json['pro_id'],
            quantity: json['quantity'],
            regular_price: json['regular_price'],
            sale_price: json['sale_price'],
            sku: json['sku'],
            stock_quantity: json['stock_quantity'],
            stock_status: json['stock_status'],
            thumbnail: json['thumbnail'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['cart_id'] = this.cart_id;
        data['created_at'] = this.created_at;
        data['full'] = this.full;
        data['name'] = this.name;
        data['price'] = this.price;
        data['pro_id'] = this.pro_id;
        data['quantity'] = this.quantity;
        data['regular_price'] = this.regular_price;
        if (this.sale_price != null) {
            data['sale_price'] = this.sale_price;
        }
        data['sku'] = this.sku;
        data['stock_quantity'] = this.stock_quantity;
        data['stock_status'] = this.stock_status;
        data['thumbnail'] = this.thumbnail;
        if (this.gallery != null) {
            data['gallery'] = this.gallery;
        }
        return data;
    }
}