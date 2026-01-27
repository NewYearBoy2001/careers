import 'package:equatable/equatable.dart';
import '../../data/models/admission_banner.dart';

abstract class AdmissionState extends Equatable {
  const AdmissionState();

  @override
  List<Object?> get props => [];
}

class AdmissionInitial extends AdmissionState {
  const AdmissionInitial();
}

class AdmissionLoading extends AdmissionState {
  const AdmissionLoading();
}

class AdmissionBannersLoaded extends AdmissionState {
  final List<AdmissionBanner> banners;

  const AdmissionBannersLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class AdmissionError extends AdmissionState {
  final String message;

  const AdmissionError(this.message);

  @override
  List<Object?> get props => [message];
}