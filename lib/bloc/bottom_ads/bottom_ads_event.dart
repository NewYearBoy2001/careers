import 'package:equatable/equatable.dart';

abstract class BottomAdsEvent extends Equatable {
  const BottomAdsEvent();
  @override
  List<Object?> get props => [];
}

class FetchBottomAds extends BottomAdsEvent {}