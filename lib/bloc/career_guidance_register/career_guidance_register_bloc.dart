import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/data/repositories/career_guidance_register_repository.dart';
import 'career_guidance_register_event.dart';
import 'career_guidance_register_state.dart';

class CareerGuidanceRegisterBloc
    extends Bloc<CareerGuidanceRegisterEvent, CareerGuidanceRegisterState> {
  final CareerGuidanceRegisterRepository _repository;

  CareerGuidanceRegisterBloc(this._repository)
      : super(CareerGuidanceRegisterInitial()) {
    on<SubmitCareerGuidanceRegistration>(_onSubmit);
    on<ResetCareerGuidanceRegistration>(_onReset);
  }

  Future<void> _onSubmit(
      SubmitCareerGuidanceRegistration event,
      Emitter<CareerGuidanceRegisterState> emit,
      ) async {
    emit(CareerGuidanceRegisterLoading());
    try {
      final id = await _repository.register(
        bannerId: event.bannerId,
        name: event.name,
        email: event.email,
        phone: event.phone,
      );
      emit(CareerGuidanceRegisterSuccess(id));
    } catch (e) {
      emit(CareerGuidanceRegisterError(e.toString()));
    }
  }

  void _onReset(
      ResetCareerGuidanceRegistration event,
      Emitter<CareerGuidanceRegisterState> emit,
      ) {
    emit(CareerGuidanceRegisterInitial());
  }
}