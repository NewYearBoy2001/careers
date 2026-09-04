import 'package:equatable/equatable.dart';
import 'package:careers/data/models/bottom_ad_model.dart';

abstract class BottomAdsState extends Equatable {
  const BottomAdsState();
  @override
  List<Object?> get props => [];
}

class BottomAdsInitial extends BottomAdsState {}

class BottomAdsLoading extends BottomAdsState {}

class BottomAdsLoaded extends BottomAdsState {
  final List<BottomAdModel> ads;
  const BottomAdsLoaded(this.ads);
  @override
  List<Object?> get props => [ads];
}

class BottomAdsError extends BottomAdsState {
  final String message;
  const BottomAdsError(this.message);
  @override
  List<Object?> get props => [message];
}