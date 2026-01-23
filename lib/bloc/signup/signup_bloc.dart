import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import '../../data/repositories/auth_repository.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository repository;

  SignupBloc({required this.repository}) : super(SignupInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  Future<void> _onSignupSubmitted(
      SignupSubmitted event,
      Emitter<SignupState> emit,
      ) async {
    emit(SignupLoading());

    try {
      final response = await repository.signup(body: event.body);

      if (response.success) {
        emit(SignupSuccess(response.message));
      } else {
        emit(SignupFailure(response.message));
      }
    } catch (e) {
      emit(SignupFailure("Signup failed. Please try again."));
    }
  }
}

