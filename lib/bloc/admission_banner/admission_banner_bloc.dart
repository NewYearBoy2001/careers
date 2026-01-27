import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admission_banner_repository.dart';
import 'admission_banner_state.dart';
import 'admission_banner_event.dart';

class AdmissionBloc extends Bloc<AdmissionEvent, AdmissionState> {
  final AdmissionRepository _repository;

  AdmissionBloc(this._repository) : super(const AdmissionInitial()) {
    on<FetchAdmissionBanners>(_onFetchBanners);
  }

  Future<void> _onFetchBanners(
      FetchAdmissionBanners event,
      Emitter<AdmissionState> emit,
      ) async {
    emit(const AdmissionLoading());

    final response = await _repository.fetchBanners();

    if (response.success && response.data != null) {
      emit(AdmissionBannersLoaded(response.data!));
    } else {
      emit(AdmissionError(response.message));
    }
  }
}