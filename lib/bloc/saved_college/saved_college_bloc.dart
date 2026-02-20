import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/saved_college_repository.dart';
import 'saved_college_event.dart';
import 'saved_college_state.dart';

class SavedCollegeBloc extends Bloc<SavedCollegeEvent, SavedCollegeState> {
  final SavedCollegeRepository repository;

  SavedCollegeBloc(this.repository) : super(SavedCollegeInitial()) {
    on<SaveCollege>(_onSaveCollege);
    on<RemoveSavedCollege>(_onRemoveSavedCollege);
  }

  /// Handle saving a college
  Future<void> _onSaveCollege(
      SaveCollege event,
      Emitter<SavedCollegeState> emit,
      ) async {
    emit(SavedCollegeActionLoading());
    try {
      final message = await repository.saveCollege(event.collegeId);
      emit(CollegeSaved(
        message: message,
        collegeId: event.collegeId,
      ));
    } catch (e) {
      emit(SavedCollegeError(e.toString()));
    }
  }

  /// Handle removing a saved college
  Future<void> _onRemoveSavedCollege(
      RemoveSavedCollege event,
      Emitter<SavedCollegeState> emit,
      ) async {
    emit(SavedCollegeActionLoading());
    try {
      final message = await repository.removeSavedCollege(event.collegeId);
      emit(CollegeUnsaved(
        message: message,
        collegeId: event.collegeId,
      ));
    } catch (e) {
      emit(SavedCollegeError(e.toString()));
    }
  }

}