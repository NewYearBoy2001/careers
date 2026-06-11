class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String collegeId;
  final String college;
  final String location;
  final String rating;
  final String courses;
  final String createdAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.collegeId,
    required this.college,
    required this.location,
    required this.rating,
    required this.courses,
    required this.createdAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      collegeId: json['college_id']?.toString() ?? '',
      college: json['college'] ?? '',
      location: json['location'] ?? '',
      rating: json['rating'] ?? '0.0',
      courses: json['courses'] ?? '',
      createdAt: json['created_at'] ?? '',
      timeAgo: json['time_ago'] ?? '',
    );
  }
}