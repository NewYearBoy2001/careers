import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/career_search_repository.dart';
import '../../utils/network/api_error_handler.dart';
import 'career_search_event.dart';
import 'career_search_state.dart';

class CareerSearchBloc extends Bloc<CareerSearchEvent, CareerSearchState> {
  final CareerSearchRepository _repository;
  String _lastKeyword = '';

  CareerSearchBloc(this._repository) : super(CareerSearchInitial()) {
    on<SearchCareersEvent>(_onSearchCareers);
    on<LoadMoreCareersEvent>(_onLoadMore);
    on<FetchCareerDetailsEvent>(_onFetchCareerDetails);
    on<ClearSearchResultsEvent>(_onClearSearchResults);
  }

  Future<void> _onSearchCareers(
      SearchCareersEvent event,
      Emitter<CareerSearchState> emit,
      ) async {
    _lastKeyword = event.keyword;
    emit(CareerSearchLoading());
    try {
      final response = await _repository.searchCareers(event.keyword, page: 1);
      emit(CareerSearchLoaded(
        careers: response.careernodes,
        totalCount: response.totalNodes,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
      ));
    } on DioException catch (e) {
      emit(CareerSearchError(ApiErrorHandler.handleDioError(e)));
    } catch (e) {
      emit(CareerSearchError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreCareersEvent event,
      Emitter<CareerSearchState> emit,
      ) async {
    final current = state;
    if (current is! CareerSearchLoaded || !current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final response = await _repository.searchCareers(
        _lastKeyword,
        page: current.currentPage + 1,
      );
      emit(current.copyWith(
        careers: [...current.careers, ...response.careernodes],
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        totalCount: response.totalNodes,
        isLoadingMore: false,
      ));
    } on DioException catch (e) {
      // On error, just stop the loading indicator — keep existing results
      emit(current.copyWith(isLoadingMore: false));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onFetchCareerDetails(
      FetchCareerDetailsEvent event,
      Emitter<CareerSearchState> emit,
      ) async {
    emit(CareerDetailsLoading());
    try {
      final careerDetails = await _repository.getCareerNodeDetails(event.careerNodeId);
      emit(CareerDetailsLoaded(careerDetails));
    } on DioException catch (e) {
      emit(CareerDetailsError(ApiErrorHandler.handleDioError(e)));
    } catch (e) {
      emit(CareerDetailsError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onClearSearchResults(
      ClearSearchResultsEvent event,
      Emitter<CareerSearchState> emit,
      ) async {
    _lastKeyword = '';
    emit(CareerSearchInitial());
  }
}