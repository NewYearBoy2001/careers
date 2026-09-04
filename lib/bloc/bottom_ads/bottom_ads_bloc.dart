import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/bloc/bottom_ads/bottom_ads_event.dart';
import 'package:careers/bloc/bottom_ads/bottom_ads_state.dart';
import 'package:careers/data/repositories/bottom_ads_repository.dart';

class BottomAdsBloc extends Bloc<BottomAdsEvent, BottomAdsState> {
  final BottomAdsRepository repository;

  BottomAdsBloc(this.repository) : super(BottomAdsInitial()) {
    on<FetchBottomAds>(_onFetch);
  }

  Future<void> _onFetch(
      FetchBottomAds event,
      Emitter<BottomAdsState> emit,
      ) async {
    emit(BottomAdsLoading());
    try {
      final ads = await repository.getBottomAds();
      emit(BottomAdsLoaded(ads));
    } catch (e) {
      emit(BottomAdsError(e.toString()));
    }
  }
}