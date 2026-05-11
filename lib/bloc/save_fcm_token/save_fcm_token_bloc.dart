import 'package:careers/data/repositories/save_fcm_token_repository.dart';
import 'save_fcm_token_event.dart';
import 'save_fcm_token_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaveFcmTokenBloc extends Bloc<SaveFcmTokenEvent, SaveFcmTokenState> {
  final SaveFcmTokenRepository _repository;

  SaveFcmTokenBloc(this._repository) : super(SaveFcmTokenInitial()) {
    on<SaveFcmTokenRequested >((event, emit) async {
      try {
        await _repository.saveFcmToken(event.fcmKey);
        emit(SaveFcmTokenSuccess());
      } catch (_) {
        emit(SaveFcmTokenFailure());
      }
    });
  }
}