import 'package:flutter_bloc/flutter_bloc.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';
import '../../data/repositories/forgot_password_repository.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordRepository _repository;

  ForgotPasswordBloc(this._repository) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPassword);
    on<ResetPasswordSubmitted>(_onResetPassword);
  }

  Future<void> _onForgotPassword(
      ForgotPasswordSubmitted event,
      Emitter<ForgotPasswordState> emit,
      ) async {
    emit(ForgotPasswordLoading());
    try {
      final message = await _repository.forgotPassword(event.email);
      emit(ForgotPasswordSuccess(message));
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }

  Future<void> _onResetPassword(
      ResetPasswordSubmitted event,
      Emitter<ForgotPasswordState> emit,
      ) async {
    emit(ResetPasswordLoading());
    try {
      final message = await _repository.resetPassword(
        email: event.email,
        otp: event.otp,
        password: event.password,
      );
      emit(ResetPasswordSuccess(message));
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }
}