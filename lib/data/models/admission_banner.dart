class AdmissionBanner {
  final String id;
  final String title;
  final String imageUrl;
  // final String? description;
  // final String? link;

  AdmissionBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    // this.description,
    // this.link,
  });

  factory AdmissionBanner.fromJson(Map<String, dynamic> json) {
    return AdmissionBanner(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      // description: json['description'],
      // link: json['link'],
    );
  }
}