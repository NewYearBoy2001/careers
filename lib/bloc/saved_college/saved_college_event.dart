import 'package:equatable/equatable.dart';

abstract class SavedCollegeEvent extends Equatable {
  const SavedCollegeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to save a college
class SaveCollege extends SavedCollegeEvent {
  final String collegeId;
  final String userId;

  const SaveCollege(this.collegeId, this.userId);

  @override
  List<Object?> get props => [collegeId, userId];
}

class RemoveSavedCollege extends SavedCollegeEvent {
  final String collegeId;
  final String userId;

  const RemoveSavedCollege(this.collegeId, this.userId);

  @override
  List<Object?> get props => [collegeId, userId];
}

