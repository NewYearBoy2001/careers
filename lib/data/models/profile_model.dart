class ProfileModel {
  final String userId;
  final String role;
  final String name;
  final String email;
  final String phone;
  final String? currentEducation; // For Student
  final List<ChildModel>? children; // For Parent

  ProfileModel({
    required this.userId,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    this.currentEducation,
    this.children,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      currentEducation: json['current_education'],
      children: json['children'] != null
          ? (json['children'] as List)
          .map((child) => ChildModel.fromJson(child))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      if (currentEducation != null) 'current_education': currentEducation,
      if (children != null)
        'children': children!.map((child) => child.toJson()).toList(),
    };
  }

  bool isStudent() => role == 'Student';
  bool isParent() => role == 'Parent';
}

class ChildModel {
  final String id;
  final String name;
  final String educationLevel;

  ChildModel({
    required this.id,
    required this.name,
    required this.educationLevel,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      educationLevel: json['education_level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'education_level': educationLevel,
    };
  }
}