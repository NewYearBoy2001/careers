import 'package:careers/data/models/admission_banner.dart';

abstract class AdmissionState {}

class AdmissionInitial extends AdmissionState {}

class AdmissionLoading extends AdmissionState {}

class AdmissionLoaded extends AdmissionState {
  final List<AdmissionBanner> banners;

  AdmissionLoaded(this.banners);
}

class AdmissionError extends AdmissionState {
  final String message;

  AdmissionError(this.message);
}
