class NewgenCourse {
  final String id;
  final String title;
  final String? thumbnail;
  final bool isNewgenCourse;

  NewgenCourse({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.isNewgenCourse,
  });

  factory NewgenCourse.fromJson(Map<String, dynamic> json) {
    return NewgenCourse(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      thumbnail: (json['thumbnail']?.toString() ?? '').trim().isEmpty
          ? null
          : json['thumbnail'].toString().trim(),
      isNewgenCourse: json['is_newgen_course'] == 1 ||
          json['is_newgen_course'] == '1' ||
          json['is_newgen_course'] == true,
    );
  }
}

class NewgenCoursesResponse {
  final List<NewgenCourse> courses;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int totalCourses;

  NewgenCoursesResponse({
    required this.courses,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.totalCourses,
  });

  factory NewgenCoursesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return NewgenCoursesResponse(
      courses: (data['newgen_courses'] as List? ?? [])
          .map((e) => NewgenCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage:
      int.tryParse(data['current_page']?.toString() ?? '1') ?? 1,
      lastPage: int.tryParse(data['last_page']?.toString() ?? '1') ?? 1,
      perPage: int.tryParse(data['per_page']?.toString() ?? '10') ?? 10,
      totalCourses:
      int.tryParse(data['total_courses']?.toString() ?? '0') ?? 0,
    );
  }
}