class AdmissionBanner {
  final String id;
  final String title;
  final String imageUrl;

  AdmissionBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory AdmissionBanner.fromJson(Map<String, dynamic> json) {
    return AdmissionBanner(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
