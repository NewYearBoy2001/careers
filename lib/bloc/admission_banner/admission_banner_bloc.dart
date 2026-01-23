import 'package:flutter_bloc/flutter_bloc.dart';
import 'admission_banner_event.dart';
import 'admission_banner_state.dart';
import 'package:careers/data/repositories/admission_banner_repository.dart';

class AdmissionBloc extends Bloc<AdmissionEvent, AdmissionState> {
  final AdmissionRepository repository;

  AdmissionBloc(this.repository) : super(AdmissionInitial()) {
    on<LoadAdmissionBanners>(_onLoadBanners);
  }

  Future<void> _onLoadBanners(
      LoadAdmissionBanners event,
      Emitter<AdmissionState> emit,
      ) async {
    emit(AdmissionLoading());

    try {
      final banners = await repository.getBanners();
      emit(AdmissionLoaded(banners));
    } catch (e) {
      emit(AdmissionError(e.toString()));
    }
  }
}
