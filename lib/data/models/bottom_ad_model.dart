class BottomAdModel {
  final String id;
  final String image;
  final String poster;
  final String? link;

  BottomAdModel({
    required this.id,
    required this.image,
    required this.poster,
    this.link,
  });

  factory BottomAdModel.fromJson(Map<String, dynamic> json) {
    return BottomAdModel(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
      link: (json['link'] == null || json['link'].toString().isEmpty)
          ? null
          : json['link'].toString(),
    );
  }
}