import 'package:equatable/equatable.dart';
import '../../data/models/course_fee_model.dart';

abstract class CourseFeeState extends Equatable {
  const CourseFeeState();
  @override
  List<Object?> get props => [];
}

class CourseFeeInitial extends CourseFeeState {}

class CourseFeeLoading extends CourseFeeState {}

class CourseFeeLoaded extends CourseFeeState {
  final CourseFeeModel data;
  const CourseFeeLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class CourseFeeError extends CourseFeeState {
  final String message;
  const CourseFeeError(this.message);
  @override
  List<Object?> get props => [message];
}