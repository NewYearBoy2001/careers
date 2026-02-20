import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/career_search_repository.dart';
import '../../utils/network/api_error_handler.dart';
import 'career_search_event.dart';
import 'career_search_state.dart';

class CareerSearchBloc extends Bloc<CareerSearchEvent, CareerSearchState> {
  final CareerSearchRepository _repository;

  CareerSearchBloc(this._repository) : super(CareerSearchInitial()) {
    on<SearchCareersEvent>(_onSearchCareers);
    on<FetchCareerDetailsEvent>(_onFetchCareerDetails);
    on<ClearSearchResultsEvent>(_onClearSearchResults);
  }

  Future<void> _onSearchCareers(
      SearchCareersEvent event,
      Emitter<CareerSearchState> emit,
      ) async {
    emit(CareerSearchLoading());
    try {
      final response = await _repository.searchCareers(event.keyword);
      emit(
        CareerSearchLoaded(
          careers: response.careernodes,
          totalCount: response.totalNodes,
        ),
      );
    } on DioException catch (e) {
      final errorMessage = ApiErrorHandler.handleDioError(e);
      emit(CareerSearchError(errorMessage));
    } catch (e) {
      emit(CareerSearchError('An unexpected error occurred: $e'));
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
      final errorMessage = ApiErrorHandler.handleDioError(e);
      emit(CareerDetailsError(errorMessage));
    } catch (e) {
      emit(CareerDetailsError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onClearSearchResults(
      ClearSearchResultsEvent event,
      Emitter<CareerSearchState> emit,
      ) async {
    emit(CareerSearchInitial());
  }
}