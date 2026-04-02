import 'package:equatable/equatable.dart';

abstract class CourseFeeEvent extends Equatable {
  const CourseFeeEvent();
  @override
  List<Object?> get props => [];
}

class FetchCourseFee extends CourseFeeEvent {
  final String courseId;
  const FetchCourseFee(this.courseId);
  @override
  List<Object?> get props => [courseId];
}