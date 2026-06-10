class ArticleModel {
  final int id;
  final String title;
  final String fileUrl;
  final String createdAt;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.createdAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
    id: int.parse(json['id'].toString()),
    title: json['title'] as String,
    fileUrl: json['file_url'] as String,
    createdAt: json['created_at'] as String,
  );
}