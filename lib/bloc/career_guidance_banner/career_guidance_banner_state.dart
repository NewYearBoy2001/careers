import 'package:careers/data/models/career_guidance_banner_model.dart';

abstract class CareerGuidanceBannerState {}

class CareerGuidanceBannerInitial extends CareerGuidanceBannerState {}

class CareerGuidanceBannerLoading extends CareerGuidanceBannerState {}

class CareerGuidanceBannerLoaded extends CareerGuidanceBannerState {
  final List<CareerGuidanceBannerModel> banners;
  CareerGuidanceBannerLoaded(this.banners);
}

class CareerGuidanceBannerError extends CareerGuidanceBannerState {
  final String message;
  CareerGuidanceBannerError(this.message);
}