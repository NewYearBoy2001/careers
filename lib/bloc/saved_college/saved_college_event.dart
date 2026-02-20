import 'package:equatable/equatable.dart';

abstract class SavedCollegeEvent extends Equatable {
  const SavedCollegeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to save a college
class SaveCollege extends SavedCollegeEvent {
  final String collegeId;

  const SaveCollege(this.collegeId);

  @override
  List<Object?> get props => [collegeId];
}

/// Event to remove a saved college
class RemoveSavedCollege extends SavedCollegeEvent {
  final String collegeId;

  const RemoveSavedCollege(this.collegeId);

  @override
  List<Object?> get props => [collegeId];
}
