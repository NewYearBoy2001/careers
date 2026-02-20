import 'package:flutter_bloc/flutter_bloc.dart';
import 'saved_colleges_list_event.dart';
import 'saved_colleges_list_state.dart';
import '../../data/repositories/saved_colleges_list_repository.dart';

class SavedCollegesListBloc extends Bloc<SavedCollegesListEvent, SavedCollegesListState> {
  final SavedCollegesListRepository _repository;

  SavedCollegesListBloc(this._repository) : super(SavedCollegesListInitial()) {
    on<FetchSavedCollegesList>(_onFetchSavedCollegesList);
    on<RefreshSavedCollegesList>(_onRefreshSavedCollegesList);
  }

  Future<void> _onFetchSavedCollegesList(
      FetchSavedCollegesList event,
      Emitter<SavedCollegesListState> emit,
      ) async {
    emit(SavedCollegesListLoading());
    try {
      final colleges = await _repository.getSavedColleges();

      if (colleges.isEmpty) {
        emit(SavedCollegesListEmpty('No saved colleges found'));
      } else {
        emit(SavedCollegesListLoaded(colleges));
      }
    } catch (e) {
      emit(SavedCollegesListError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshSavedCollegesList(
      RefreshSavedCollegesList event,
      Emitter<SavedCollegesListState> emit,
      ) async {
    // Don't show loading on refresh, keep current state
    try {
      final colleges = await _repository.getSavedColleges();

      if (colleges.isEmpty) {
        emit(SavedCollegesListEmpty('No saved colleges found'));
      } else {
        emit(SavedCollegesListLoaded(colleges));
      }
    } catch (e) {
      emit(SavedCollegesListError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}