import '../../data/models/career_banner_model.dart';

abstract class CareerBannerState {}

class CareerBannerInitial extends CareerBannerState {}

class CareerBannerLoading extends CareerBannerState {}

class CareerBannerLoaded extends CareerBannerState {
  final List<CareerBannerModel> banners;
  final String totalBanners;

  CareerBannerLoaded({
    required this.banners,
    required this.totalBanners,
  });
}

class CareerBannerError extends CareerBannerState {
  final String message;

  CareerBannerError(this.message);
}