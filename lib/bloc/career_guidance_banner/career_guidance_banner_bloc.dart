import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/data/repositories/career_guidance_banner_repository.dart';
import 'career_guidance_banner_event.dart';
import 'career_guidance_banner_state.dart';

class CareerGuidanceBannerBloc
    extends Bloc<CareerGuidanceBannerEvent, CareerGuidanceBannerState> {
  final CareerGuidanceBannerRepository _repository;

  CareerGuidanceBannerBloc(this._repository)
      : super(CareerGuidanceBannerInitial()) {
    on<FetchCareerGuidanceBanners>(_onFetch);
    on<RefreshCareerGuidanceBanners>(_onRefresh);
  }

  Future<void> _onRefresh(
      RefreshCareerGuidanceBanners event,
      Emitter<CareerGuidanceBannerState> emit,
      ) async {
    // No loading state emitted — current data stays visible
    try {
      final banners = await _repository.fetchBanners();
      emit(CareerGuidanceBannerLoaded(banners));
    } catch (_) {
      // Silently fail — don't replace existing data with an error
    }
  }

  Future<void> _onFetch(
      FetchCareerGuidanceBanners event,
      Emitter<CareerGuidanceBannerState> emit,
      ) async {
    emit(CareerGuidanceBannerLoading());
    try {
      final banners = await _repository.fetchBanners();
      emit(CareerGuidanceBannerLoaded(banners));
    } catch (e) {
      emit(CareerGuidanceBannerError(e.toString()));
    }
  }
}