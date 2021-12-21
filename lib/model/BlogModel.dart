class BlogModel {
  String image;
  String description;
  String title;
  String publish_date;

  BlogModel({
    this.image,
    this.description,
    this.title,
    this.publish_date,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      image: json['image'],
      description: json['description'],
      title: json['title'],
      publish_date: json['publish_date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['description'] = this.description;
    data['title'] = this.title;
    data['publish_date'] = this.publish_date;
    return data;
  }
}
