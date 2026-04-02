class CourseItem {
  final String courseId;
  final String courseName;

  CourseItem({required this.courseId, required this.courseName});

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
    );
  }
}

class CollegeModel {
  final String id;
  final String name;
  final String location;
  final String rating;
  final List<CourseItem> courseList;
  final String? phone;
  final String? email;
  final String? website;
  final String? about;
  final List<String>? images;
  final List<String>? facilities;
  final bool? isSaved;

  CollegeModel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.courseList,
    this.phone,
    this.email,
    this.website,
    this.about,
    this.images,
    this.facilities,
    this.isSaved,
  });

  String get coursesDisplay => courseList.map((c) => c.courseName).join(', ');

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    // ✅ Handle BOTH string and list formats from different APIs
    List<CourseItem> parsedCourses = [];
    final rawCourses = json['courses'];

    if (rawCourses is List) {
      // college-details API: [{"course_id": "1", "course_name": "BBA"}]
      parsedCourses = rawCourses
          .map((c) => CourseItem.fromJson(c as Map<String, dynamic>))
          .toList();
    } else if (rawCourses is String && rawCourses.isNotEmpty) {
      // search-colleges API: "Bsc cs, Bcom, Bba"
      parsedCourses = rawCourses
          .split(',')
          .map((name) => CourseItem(courseId: '', courseName: name.trim()))
          .toList();
    }

    return CollegeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '0.0',
      courseList: parsedCourses,
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      about: json['about']?.toString(),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : null,
      isSaved: json['is_saved'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'courses': courseList,
      'phone': phone,
      'email': email,
      'website': website,
      'about': about,
      'images': images,
      'facilities': facilities,
    };
  }
}