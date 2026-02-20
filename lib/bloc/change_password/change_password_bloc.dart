import 'package:flutter_bloc/flutter_bloc.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';
import '../../data/repositories/change_password_repository.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ChangePasswordRepository _repository;

  ChangePasswordBloc(this._repository) : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
  }

  Future<void> _onChangePasswordSubmitted(
      ChangePasswordSubmitted event,
      Emitter<ChangePasswordState> emit,
      ) async {
    emit(ChangePasswordLoading());

    try {
      final response = await _repository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      final message = response['message'] ?? 'Password changed successfully';
      emit(ChangePasswordSuccess(message));
    } catch (e) {
      emit(ChangePasswordError(e.toString()));
    }
  }
}