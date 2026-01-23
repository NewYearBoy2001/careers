class UserModel {
  final String userId;
  final String authToken;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.userId,
    required this.authToken,
    required this.name,
    required this.email,
    required this.role,
  });
}
