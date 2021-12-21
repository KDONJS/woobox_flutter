class LoginResponse {
  String avatar;
  String token;
  String user_display_name;
  String user_email;
  int user_id;
  String user_nicename;
  String profile_image;
  List<String> user_role;

  LoginResponse(
      {this.avatar,
      this.token,
      this.user_display_name,
      this.user_email,
      this.user_id,
      this.user_nicename,
      this.profile_image,
      this.user_role});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      avatar: json['avatar'],
      token: json['token'],
      user_display_name: json['user_display_name'],
      user_email: json['user_email'],
      user_id: json['user_id'],
      user_nicename: json['user_nicename'],
      profile_image: json['profile_image'],
      user_role: json['user_role'] != null
          ? new List<String>.from(json['user_role'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['token'] = this.token;
    data['user_display_name'] = this.user_display_name;
    data['user_email'] = this.user_email;
    data['user_id'] = this.user_id;
    data['user_nicename'] = this.user_nicename;
    data['profile_image'] = this.profile_image;
    if (this.user_role != null) {
      data['user_role'] = this.user_role;
    }
    return data;
  }
}
