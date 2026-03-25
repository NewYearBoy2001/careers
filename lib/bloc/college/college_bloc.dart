import 'package:flutter_bloc/flutter_bloc.dart';
import 'college_event.dart';
import 'college_state.dart';
import '../../data/repositories/college_repository.dart';
import '../../data/models/college_model.dart';

class CollegeBloc extends Bloc<CollegeEvent, CollegeState> {
  final CollegeRepository _repository;
  List<CollegeModel> _lastSearchResults = [];
  List<CollegeModel> _accumulatedColleges = []; // for pagination append
  String? _lastKeyword;
  String? _lastLocation;

  CollegeBloc(this._repository) : super(CollegeInitial()) {
    on<SearchColleges>(_onSearchColleges);
    on<FetchCollegeDetails>(_onFetchCollegeDetails);
  }

  Future<void> _onSearchColleges(
      SearchColleges event,
      Emitter<CollegeState> emit,
      ) async {
    // If page 1, it's a fresh search — reset accumulated list
    if (event.page == 1) {
      _accumulatedColleges = [];
      _lastKeyword = event.keyword;
      _lastLocation = event.location;
      emit(CollegeSearchLoading());
    }
    // else it's a "load more" — don't show full loading, keep existing list

    try {
      final response = await _repository.searchColleges(
        keyword: event.keyword,
        location: event.location,
        page: event.page,
        perPage: event.perPage,
      );

      if (response.success && response.data != null) {
        _accumulatedColleges = [..._accumulatedColleges, ...response.data!];
        _lastSearchResults = _accumulatedColleges;
        emit(CollegeSearchLoaded(
          _lastSearchResults,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          totalColleges: response.totalColleges,
        ));
      } else {
        emit(CollegeError(response.message ?? 'Failed to fetch colleges'));
      }
    } catch (e) {
      emit(CollegeError('An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCollegeDetails(
      FetchCollegeDetails event,
      Emitter<CollegeState> emit,
      ) async {
    emit(CollegeDetailsLoading(_lastSearchResults)); // ✅ CHANGE: Pass preserved results

    try {
      final response = await _repository.getCollegeDetails(event.collegeId);

      if (response.success && response.data != null) {
        emit(CollegeDetailsLoaded(response.data!, _lastSearchResults)); // ✅ CHANGE: Pass preserved results
      } else {
        emit(CollegeError(
          response.message ?? 'Failed to fetch college details',
          colleges: _lastSearchResults, // ✅ CHANGE: Pass preserved results on error
        ));
      }
    } catch (e) {
      emit(CollegeError(
        'An error occurred: ${e.toString()}',
        colleges: _lastSearchResults, // ✅ CHANGE: Pass preserved results on error
      ));
    }
  }
}