import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/data/repositories/delete_account_repository.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountRepository _repository;

  DeleteAccountBloc(this._repository) : super(DeleteAccountInitial()) {
    on<DeleteAccountSubmitted>(_onDeleteAccountSubmitted);
  }

  Future<void> _onDeleteAccountSubmitted(
      DeleteAccountSubmitted event,
      Emitter<DeleteAccountState> emit,
      ) async {
    emit(DeleteAccountLoading());
    try {
      final message = await _repository.deleteAccount(
        reason: event.reason,
        confirmation: event.confirmation,
      );
      emit(DeleteAccountSuccess(message));
    } catch (e) {
      emit(DeleteAccountFailure(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}