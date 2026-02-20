class CareerBannerModel {
  final String id;
  final String title;
  final String image;

  CareerBannerModel({
    required this.id,
    required this.title,
    required this.image,
  });

  factory CareerBannerModel.fromJson(Map<String, dynamic> json) {
    return CareerBannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
    };
  }
}

class CareerBannerResponse {
  final String status;
  final String statusCode;
  final List<CareerBannerModel> banners;
  final String totalBanners;
  final String message;

  CareerBannerResponse({
    required this.status,
    required this.statusCode,
    required this.banners,
    required this.totalBanners,
    required this.message,
  });

  factory CareerBannerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final bannersList = data['banners'] as List<dynamic>? ?? [];

    return CareerBannerResponse(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      banners: bannersList
          .map((banner) => CareerBannerModel.fromJson(banner as Map<String, dynamic>))
          .toList(),
      totalBanners: data['total_banners']?.toString() ?? '0',
      message: json['message']?.toString() ?? '',
    );
  }
}