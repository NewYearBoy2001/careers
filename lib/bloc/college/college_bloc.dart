import 'package:flutter_bloc/flutter_bloc.dart';
import 'college_event.dart';
import 'college_state.dart';
import '../../data/repositories/college_repository.dart';
import '../../data/models/college_model.dart';

class CollegeBloc extends Bloc<CollegeEvent, CollegeState> {
  final CollegeRepository _repository;
  List<CollegeModel> _lastSearchResults = [];
  List<CollegeModel> _accumulatedColleges = [];
  String? _lastKeyword;
  String? _lastLocation;
  int _searchGeneration = 0; // ← ADD THIS

  CollegeBloc(this._repository) : super(CollegeInitial()) {
    on<SearchColleges>(_onSearchColleges);
    on<FetchCollegeDetails>(_onFetchCollegeDetails);
  }

  Future<void> _onSearchColleges(
      SearchColleges event,
      Emitter<CollegeState> emit,
      ) async {
    if (event.page == 1) {
      _accumulatedColleges = [];
      _lastKeyword = event.keyword;
      _lastLocation = event.location;
      _searchGeneration++; // ← INCREMENT on every new search
      emit(CollegeSearchLoading());
    }

    final int myGeneration = _searchGeneration; // ← CAPTURE current generation

    try {
      final response = await _repository.searchColleges(
        keyword: event.keyword,
        location: event.location,
        page: event.page,
        perPage: event.perPage,
      );

      // ← DISCARD result if a newer search has started
      if (myGeneration != _searchGeneration) return;

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
      if (myGeneration != _searchGeneration) return; // ← also guard here
      emit(CollegeError('An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCollegeDetails(
      FetchCollegeDetails event,
      Emitter<CollegeState> emit,
      ) async {
    emit(CollegeDetailsLoading(_lastSearchResults));

    try {
      final response = await _repository.getCollegeDetails(event.collegeId, event.userId);

      if (response.success && response.data != null) {
        emit(CollegeDetailsLoaded(response.data!, _lastSearchResults));
      } else {
        emit(CollegeError(
          response.message ?? 'Failed to fetch college details',
          colleges: _lastSearchResults,
        ));
      }
    } catch (e) {
      emit(CollegeError(
        'An error occurred: ${e.toString()}',
        colleges: _lastSearchResults,
      ));
    }
  }
}