import '../../data/models/college_model.dart';

abstract class SavedCollegesListState {}

class SavedCollegesListInitial extends SavedCollegesListState {}

class SavedCollegesListLoading extends SavedCollegesListState {}

class SavedCollegesListLoaded extends SavedCollegesListState {
  final List<CollegeModel> colleges;

  SavedCollegesListLoaded(this.colleges);
}

class SavedCollegesListEmpty extends SavedCollegesListState {
  final String message;

  SavedCollegesListEmpty(this.message);
}

class SavedCollegesListError extends SavedCollegesListState {
  final String message;

  SavedCollegesListError(this.message);
}