class TestimonialsData {
  String name;
  String message;
  String designation;
  String company;
  String image;

  TestimonialsData({
    this.name,
    this.message,
    this.designation,
    this.company,
    this.image,
  });

  factory TestimonialsData.fromJson(Map<String, dynamic> json) {
    return TestimonialsData(
      name: json['name'],
      message: json['message'],
      designation: json['designation'],
      company: json['company'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['message'] = this.message;
    data['designation'] = this.designation;
    data['company'] = this.company;
    data['image'] = this.image;
    return data;
  }
}
