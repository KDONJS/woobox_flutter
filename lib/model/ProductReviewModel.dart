class ProductReviewModel {
    String date_created;
    String email;
    int id;
    String name;
    int rating;
    String review;
    bool verified;

    ProductReviewModel({this.date_created, this.email, this.id, this.name, this.rating, this.review, this.verified});

    factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
        return ProductReviewModel(
            date_created: json['date_created'],
            email: json['email'],
            id: json['id'],
            name: json['name'],
            rating: json['rating'],
            review: json['review'],
            verified: json['verified'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['date_created'] = this.date_created;
        data['email'] = this.email;
        data['id'] = this.id;
        data['name'] = this.name;
        data['rating'] = this.rating;
        data['review'] = this.review;
        data['verified'] = this.verified;
        return data;
    }
}