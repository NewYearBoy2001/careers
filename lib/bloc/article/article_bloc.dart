import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/models/article_model.dart';
import '../../utils/network/api_error_handler.dart'; // adjust path to match yours
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository _repository;
  static const int _perPage = 10;

  ArticleBloc(this._repository) : super(ArticleInitial()) {
    on<FetchArticles>(_onFetch);
    on<FetchMoreArticles>(_onFetchMore);
    on<RefreshArticles>(_onRefresh);
    on<SearchArticles>(_onSearch);
    on<ClearArticleSearch>(_onClearSearch);
  }

  Future<void> _onFetch(FetchArticles event, Emitter<ArticleState> emit) async {
    emit(ArticleLoading());
    try {
      final result = await _repository.fetchArticles(page: 1, perPage: _perPage);
      final articles = result['articles'] as List<ArticleModel>;
      final total = result['total'] as int;
      emit(ArticleLoaded(
        articles: articles,
        hasMore: articles.length >= _perPage,
        currentPage: 1,
        total: total,
      ));
    } on DioException catch (e) {
      emit(ArticleError(ApiErrorHandler.handleDioError(e)));
    } catch (_) {
      emit(ArticleError('Something went wrong.'));
    }
  }

  Future<void> _onFetchMore(FetchMoreArticles event, Emitter<ArticleState> emit) async {
    final current = state;
    if (current is! ArticleLoaded || current is ArticleLoadingMore || !current.hasMore) return;

    emit(ArticleLoadingMore(
      articles: current.articles,
      hasMore: current.hasMore,
      currentPage: current.currentPage,
      total: current.total,
      isSearching: current.isSearching,
      searchQuery: current.searchQuery,
    ));

    try {
      final nextPage = current.currentPage + 1;
      Map<String, dynamic> result;

      if (current.isSearching) {
        result = await _repository.searchArticles(
          query: current.searchQuery,
          page: nextPage,
          perPage: _perPage,
        );
      } else {
        result = await _repository.fetchArticles(page: nextPage, perPage: _perPage);
      }

      final more = result['articles'] as List<ArticleModel>;
      emit(ArticleLoaded(
        articles: [...current.articles, ...more],
        hasMore: more.length >= _perPage,
        currentPage: nextPage,
        total: current.total,
        isSearching: current.isSearching,
        searchQuery: current.searchQuery,
      ));
    } catch (_) {
      emit(ArticleLoaded(
        articles: current.articles,
        hasMore: current.hasMore,
        currentPage: current.currentPage,
        total: current.total,
        isSearching: current.isSearching,
        searchQuery: current.searchQuery,
      ));
    }
  }

  Future<void> _onRefresh(RefreshArticles event, Emitter<ArticleState> emit) async {
    final current = state;
    try {
      Map<String, dynamic> result;
      final wasSearching = current is ArticleLoaded && current.isSearching;
      final query = current is ArticleLoaded ? current.searchQuery : '';

      if (wasSearching) {
        result = await _repository.searchArticles(
          query: query,
          page: 1,
          perPage: _perPage,
        );
      } else {
        result = await _repository.fetchArticles(page: 1, perPage: _perPage);
      }

      final articles = result['articles'] as List<ArticleModel>;
      final total = result['total'] as int;
      emit(ArticleLoaded(
        articles: articles,
        hasMore: articles.length >= _perPage,
        currentPage: 1,
        total: total,
        isSearching: wasSearching,
        searchQuery: query,
      ));
    } on DioException catch (e) {
      if (current is ArticleLoaded) emit(current);
      else emit(ArticleError(ApiErrorHandler.handleDioError(e)));
    } catch (_) {
      if (current is ArticleLoaded) emit(current);
      else emit(ArticleError('Something went wrong.'));
    }
  }

  Future<void> _onSearch(SearchArticles event, Emitter<ArticleState> emit) async {
    if (event.query.trim().isEmpty) {
      add(ClearArticleSearch());
      return;
    }
    emit(ArticleSearchLoading());
    try {
      final result = await _repository.searchArticles(
        query: event.query,
        page: 1,
        perPage: _perPage,
      );
      final articles = result['articles'] as List<ArticleModel>;
      final total = result['total'] as int;
      emit(ArticleLoaded(
        articles: articles,
        hasMore: articles.length >= _perPage,
        currentPage: 1,
        total: total,
        isSearching: true,
        searchQuery: event.query,
      ));
    } on DioException catch (e) {
      emit(ArticleError(ApiErrorHandler.handleDioError(e)));
    } catch (_) {
      emit(ArticleError('Something went wrong.'));
    }
  }

  Future<void> _onClearSearch(ClearArticleSearch event, Emitter<ArticleState> emit) async {
    add(FetchArticles());
  }
}