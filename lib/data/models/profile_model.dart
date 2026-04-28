class ProfileModel {
  final String userId;
  final String name;
  final String? email;
  final String? phone;

  ProfileModel({
    required this.userId,
    required this.name,
    this.email,
    this.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
    );
  }

  bool get isEmpty => name.isEmpty && (email == null || email!.isEmpty) && (phone == null || phone!.isEmpty);

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
  };
}