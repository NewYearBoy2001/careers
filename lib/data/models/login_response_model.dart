import 'user_model.dart';

class LoginResponseModel {
  final String userId;
  final String authToken;
  final String name;
  final String email;
  final String role;

  LoginResponseModel({
    required this.userId,
    required this.authToken,
    required this.name,
    required this.email,
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

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      userId: json['user_id'],
      authToken: json['auth_token'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}
