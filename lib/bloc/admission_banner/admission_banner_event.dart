import 'package:equatable/equatable.dart';

abstract class AdmissionEvent extends Equatable {
  const AdmissionEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdmissionBanners extends AdmissionEvent {
  const FetchAdmissionBanners();
}