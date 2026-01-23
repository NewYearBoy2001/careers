import 'user_model.dart';

class SignupResponseModel {
  final String userId;
  final String authToken;
  final String name;
  final String email;
  final String phone;
  final String role;

  SignupResponseModel({
    required this.userId,
    required this.authToken,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  UserModel toUser() {
    return UserModel(
      userId: userId,
      authToken: authToken,
      name: name,
      email: email,
      role: role,
    );
  }

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      userId: json['user_id'],
      authToken: json['auth_token'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }
}
