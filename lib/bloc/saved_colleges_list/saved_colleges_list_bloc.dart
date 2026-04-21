import 'package:flutter_bloc/flutter_bloc.dart';
import 'saved_colleges_list_event.dart';
import 'saved_colleges_list_state.dart';
import '../../data/repositories/saved_colleges_list_repository.dart';

class SavedCollegesListBloc extends Bloc<SavedCollegesListEvent, SavedCollegesListState> {
  final SavedCollegesListRepository _repository;

  SavedCollegesListBloc(this._repository) : super(SavedCollegesListInitial()) {
    on<FetchSavedCollegesList>(_onFetch);
    on<FetchNextSavedCollegesPage>(_onFetchNext);
    on<RefreshSavedCollegesList>(_onRefresh);
    on<RemoveCollegeFromSavedList>(_onRemoveCollege);
  }

  Future<void> _onFetch(
      FetchSavedCollegesList event,
      Emitter<SavedCollegesListState> emit,
      ) async {
    emit(SavedCollegesListLoading());
    try {
      final result = await _repository.getSavedColleges(page: 1);
      if (result.colleges.isEmpty) {
        emit(SavedCollegesListEmpty('No saved colleges found'));
      } else {
        emit(SavedCollegesListLoaded(
          colleges: result.colleges,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
        ));
      }
    } catch (e) {
      emit(SavedCollegesListError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchNext(
      FetchNextSavedCollegesPage event,
      Emitter<SavedCollegesListState> emit,
      ) async {
    final current = state;
    if (current is! SavedCollegesListLoaded) return;
    if (!current.hasMore || current.isFetchingMore) return;

    emit(current.copyWith(isFetchingMore: true));
    try {
      final result = await _repository.getSavedColleges(page: current.currentPage + 1);
      emit(current.copyWith(
        colleges: [...current.colleges, ...result.colleges],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        isFetchingMore: false,
      ));
    } catch (e) {
      // On next-page error, revert isFetchingMore but keep existing data
      emit(current.copyWith(isFetchingMore: false));
    }
  }

  Future<void> _onRefresh(
      RefreshSavedCollegesList event,
      Emitter<SavedCollegesListState> emit,
      ) async {
    try {
      final result = await _repository.getSavedColleges(page: 1);
      if (result.colleges.isEmpty) {
        emit(SavedCollegesListEmpty('No saved colleges found'));
      } else {
        emit(SavedCollegesListLoaded(
          colleges: result.colleges,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
        ));
      }
    } catch (e) {
      emit(SavedCollegesListError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRemoveCollege(
      RemoveCollegeFromSavedList event,
      Emitter<SavedCollegesListState> emit,
      ) async {
    final current = state;
    if (current is! SavedCollegesListLoaded) return;

    final updated = current.colleges
        .where((c) => c.id != event.collegeId)
        .toList();

    if (updated.isEmpty) {
      emit(SavedCollegesListEmpty('No saved colleges found'));
    } else {
      emit(current.copyWith(colleges: updated));
    }
  }
}