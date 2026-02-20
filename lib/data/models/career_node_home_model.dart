class CareerNodeHomeModel {
  final String id;
  final String title;
  final List<String> careerOptions;

  CareerNodeHomeModel({
    required this.id,
    required this.title,
    required this.careerOptions,
  });

  factory CareerNodeHomeModel.fromJson(Map<String, dynamic> json) {
    return CareerNodeHomeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      careerOptions: (json['career_options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}