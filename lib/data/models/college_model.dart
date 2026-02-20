class CollegeModel {
  final String id;
  final String name;
  final String location;
  final String rating;
  final String courses;
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
    required this.courses,
    this.phone,
    this.email,
    this.website,
    this.about,
    this.images,
    this.facilities,
    this.isSaved,
  });

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    return CollegeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '0.0',
      courses: json['courses']?.toString() ?? '',
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
      'courses': courses,
      'phone': phone,
      'email': email,
      'website': website,
      'about': about,
      'images': images,
      'facilities': facilities,
    };
  }
}