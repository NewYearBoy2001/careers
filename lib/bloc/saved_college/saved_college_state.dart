import 'package:equatable/equatable.dart';

abstract class SavedCollegeState extends Equatable {
  const SavedCollegeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SavedCollegeInitial extends SavedCollegeState {}

/// Loading state when saving/removing
class SavedCollegeActionLoading extends SavedCollegeState {}

/// Success state after saving
class CollegeSaved extends SavedCollegeState {
  final String message;
  final String collegeId;

  const CollegeSaved({
    required this.message,
    required this.collegeId,
  });

  @override
  List<Object?> get props => [message, collegeId];
}

/// Success state after removing
class CollegeUnsaved extends SavedCollegeState {
  final String message;
  final String collegeId;

  const CollegeUnsaved({
    required this.message,
    required this.collegeId,
  });

  @override
  List<Object?> get props => [message, collegeId];
}

/// Error state
class SavedCollegeError extends SavedCollegeState {
  final String message;

  const SavedCollegeError(this.message);

  @override
  List<Object?> get props => [message];
}
