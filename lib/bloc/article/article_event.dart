abstract class ArticleEvent {}

class FetchArticles extends ArticleEvent {}

class FetchMoreArticles extends ArticleEvent {}

class RefreshArticles extends ArticleEvent {}

class SearchArticles extends ArticleEvent {
  final String query;
  SearchArticles(this.query);
}

class ClearArticleSearch extends ArticleEvent {}