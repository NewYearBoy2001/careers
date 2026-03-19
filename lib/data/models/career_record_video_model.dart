class CareerRecordVideoModel {
  final int id;
  final String title;
  final String about;
  final String videoId; // mapped from "url" in the API response
  final String duration;
  final String creator;

  const CareerRecordVideoModel({
    required this.id,
    required this.title,
    required this.about,
    required this.videoId,
    required this.duration,
    required this.creator,
  });

  factory CareerRecordVideoModel.fromJson(Map<String, dynamic> json) {
    return CareerRecordVideoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      about: json['about'] as String? ?? '',
      videoId: json['url'] as String, // API sends "url", we store as videoId
      duration: json['duration'] as String,
      creator: json['creator'] as String,
    );
  }
}