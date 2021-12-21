class AddressModel {
  String address_1;
  String address_2;
  String city;
  String company;
  String contact;
  String country;
  String created_at;
  String first_name;
  String ID;
  String last_name;
  String postcode;
  String state;
  String user_id;

  AddressModel(
      {this.address_1, this.address_2, this.city, this.company, this.contact, this.country, this.created_at, this.first_name, this.ID, this.last_name, this.postcode, this.state, this.user_id});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      address_1: json['address_1'],
      address_2: json['address_2'],
      city: json['city'],
      company: json['company'],
      contact: json['contact'],
      country: json['country'],
      created_at: json['created_at'],
      first_name: json['first_name'],
      ID: json['ID'],
      last_name: json['last_name'],
      postcode: json['postcode'],
      state: json['state'],
      user_id: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_1'] = this.address_1;
    data['address_2'] = this.address_2;
    data['city'] = this.city;
    data['company'] = this.company;
    data['contact'] = this.contact;
    data['country'] = this.country;
    data['created_at'] = this.created_at;
    data['first_name'] = this.first_name;
    data['ID'] = this.ID;
    data['last_name'] = this.last_name;
    data['postcode'] = this.postcode;
    data['state'] = this.state;
    data['user_id'] = this.user_id;
    return data;
  }
}
