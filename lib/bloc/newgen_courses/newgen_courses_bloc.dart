import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/newgen_courses_repository.dart';
import '../../utils/network/api_error_handler.dart';
import 'newgen_courses_event.dart';
import 'newgen_courses_state.dart';

class NewgenCoursesBloc
    extends Bloc<NewgenCoursesEvent, NewgenCoursesState> {
  final NewgenCoursesRepository _repository;

  NewgenCoursesBloc(this._repository) : super(NewgenCoursesInitial()) {
    on<FetchNewgenCourses>(_onFetch);
    on<FetchMoreNewgenCourses>(_onFetchMore);
  }

  Future<void> _onFetch(
      FetchNewgenCourses event,
      Emitter<NewgenCoursesState> emit,
      ) async {
    emit(NewgenCoursesLoading());
    try {
      final response = await _repository.fetchNewgenCourses(page: 1);
      emit(NewgenCoursesLoaded(
        courses: response.courses,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        hasReachedMax: response.currentPage >= response.lastPage,
      ));
    } on DioException catch (e) {
      emit(NewgenCoursesError(ApiErrorHandler.handleDioError(e)));
    } catch (e) {
      emit(NewgenCoursesError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onFetchMore(
      FetchMoreNewgenCourses event,
      Emitter<NewgenCoursesState> emit,
      ) async {
    final current = state;
    if (current is! NewgenCoursesLoaded ||
        current.hasReachedMax ||
        current.isFetchingMore) return;

    emit(current.copyWith(isFetchingMore: true));
    try {
      final response = await _repository.fetchNewgenCourses(
          page: current.currentPage + 1);
      final allCourses = [...current.courses, ...response.courses];
      emit(current.copyWith(
        courses: allCourses,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        isFetchingMore: false,
        hasReachedMax: response.currentPage >= response.lastPage,
      ));
    } on DioException catch (e) {
      emit(current.copyWith(isFetchingMore: false));
    } catch (_) {
      emit(current.copyWith(isFetchingMore: false));
    }
  }
}