import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/course_fee_repository.dart';
import 'course_fee_event.dart';
import 'course_fee_state.dart';

class CourseFeeBloc extends Bloc<CourseFeeEvent, CourseFeeState> {
  final CourseFeeRepository _repository;

  CourseFeeBloc(this._repository) : super(CourseFeeInitial()) {
    on<FetchCourseFee>(_onFetchCourseFee);
  }

  Future<void> _onFetchCourseFee(
      FetchCourseFee event,
      Emitter<CourseFeeState> emit,
      ) async {
    emit(CourseFeeLoading());
    try {
      final data = await _repository.fetchCourseFeeStructure(event.courseId);
      emit(CourseFeeLoaded(data));
    } catch (e) {
      emit(CourseFeeError(e.toString()));
    }
  }
}