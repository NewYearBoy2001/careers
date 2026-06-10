import '../../data/models/article_model.dart';

abstract class ArticleState {}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<ArticleModel> articles;
  final bool hasMore;
  final int currentPage;
  final int total;
  final bool isSearching;
  final String searchQuery;

  ArticleLoaded({
    required this.articles,
    required this.hasMore,
    required this.currentPage,
    required this.total,
    this.isSearching = false,
    this.searchQuery = '',
  });
}

class ArticleLoadingMore extends ArticleLoaded {
  ArticleLoadingMore({
    required super.articles,
    required super.hasMore,
    required super.currentPage,
    required super.total,
    required super.isSearching,
    required super.searchQuery,
  });
}

class ArticleSearchLoading extends ArticleState {}

class ArticleError extends ArticleState {
  final String message;
  ArticleError(this.message);
}