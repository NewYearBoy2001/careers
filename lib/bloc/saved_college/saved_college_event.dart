import 'package:equatable/equatable.dart';

abstract class SavedCollegeEvent extends Equatable {
  const SavedCollegeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to save a college
class SaveCollege extends SavedCollegeEvent {
  final String collegeId;
  final String phone;

  const SaveCollege(this.collegeId, this.phone);

  @override
  List<Object?> get props => [collegeId, phone];
}

/// Event to remove a saved college
class RemoveSavedCollege extends SavedCollegeEvent {
  final String collegeId;
  final String phone;

  const RemoveSavedCollege(this.collegeId, this.phone);

  @override
  List<Object?> get props => [collegeId, phone];
}
