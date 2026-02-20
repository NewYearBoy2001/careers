import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/career_banner_repository.dart';
import 'career_banner_event.dart';
import 'career_banner_state.dart';

class CareerBannerBloc extends Bloc<CareerBannerEvent, CareerBannerState> {
  final CareerBannerRepository _repository;

  CareerBannerBloc(this._repository) : super(CareerBannerInitial()) {
    on<FetchCareerBanners>(_onFetchCareerBanners);
  }

  Future<void> _onFetchCareerBanners(
      FetchCareerBanners event,
      Emitter<CareerBannerState> emit,
      ) async {
    emit(CareerBannerLoading());
    try {
      final response = await _repository.getCareerBanners();
      emit(CareerBannerLoaded(
        banners: response.banners,
        totalBanners: response.totalBanners,
      ));
    } catch (e) {
      emit(CareerBannerError(e.toString()));
    }
  }
}