class CareerGuidanceBannerModel {
  final String id;
  final String? title;
  final String name;
  final String instructorName;
  final String description;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String googleMeetLink;
  final String image;

  const CareerGuidanceBannerModel({
    required this.id,
    this.title,
    required this.name,
    required this.instructorName,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.googleMeetLink,
    required this.image,
  });

  factory CareerGuidanceBannerModel.fromJson(Map<String, dynamic> json) {
    return CareerGuidanceBannerModel(
      id: json['id'].toString(),
      title: json['title']?.toString(),
      name: json['name'] ?? '',
      instructorName: json['instructor_name'] ?? '',
      description: json['description'] ?? '',
      eventDate: json['event_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      googleMeetLink: json['google_meet_link'] ?? '',
      image: json['image'] ?? '',
    );
  }
}