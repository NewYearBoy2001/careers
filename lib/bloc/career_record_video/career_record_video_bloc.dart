import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/career_record_video_repository.dart';
import '../../data/models/career_record_video_model.dart';
import 'career_record_video_event.dart';
import 'career_record_video_state.dart';

class CareerRecordVideoBloc
    extends Bloc<CareerRecordVideoEvent, CareerRecordVideoState> {
  final CareerRecordVideoRepository _repository;

  int _currentPage = 1;
  bool _isFetchingMore = false;

  CareerRecordVideoBloc(this._repository)
      : super(CareerRecordVideoInitial()) {
    on<FetchHomeVideos>(_onFetchHomeVideos);
    on<FetchVideosFirstPage>(_onFetchVideosFirstPage);
    on<FetchVideosNextPage>(_onFetchVideosNextPage);
    on<RefreshVideos>(_onRefreshVideos);
    on<RefreshHomeVideos>(_onRefreshHomeVideos);
  }

  // ─── Home list ─────────────────────────────────────────────────────────────
  Future<void> _onRefreshHomeVideos(
      RefreshHomeVideos event,
      Emitter<CareerRecordVideoState> emit,
      ) async {
    try {
      final videos = await _repository.fetchHomeVideos();
      emit(HomeVideosLoaded(videos));
    } catch (_) {
      // Silently fail — existing data stays visible
      // No state change needed, _onRefresh in HomePage handles UX
    }
  }

  Future<void> _onFetchHomeVideos(
      FetchHomeVideos event,
      Emitter<CareerRecordVideoState> emit,
      ) async {
    emit(HomeVideosLoading());
    try {
      final videos = await _repository.fetchHomeVideos();
      emit(HomeVideosLoaded(videos));
    } catch (e) {
      emit(HomeVideosError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ─── Full list – first page ────────────────────────────────────────────────

  Future<void> _onFetchVideosFirstPage(
      FetchVideosFirstPage event,
      Emitter<CareerRecordVideoState> emit,
      ) async {
    _currentPage = 1;
    emit(VideosLoading());
    try {
      final result = await _repository.fetchVideos(page: 1);
      _currentPage = result.currentPage;
      emit(VideosLoaded(
        videos: result.videos,
        hasNextPage: result.hasNextPage,
      ));
    } catch (e) {
      emit(VideosError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  // ─── Full list – next page ─────────────────────────────────────────────────

  Future<void> _onFetchVideosNextPage(
      FetchVideosNextPage event,
      Emitter<CareerRecordVideoState> emit,
      ) async {
    final current = state;
    if (current is! VideosLoaded) return;
    if (!current.hasNextPage || _isFetchingMore) return;

    _isFetchingMore = true;
    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final result = await _repository.fetchVideos(page: nextPage);
      _currentPage = result.currentPage;

      final merged = List<CareerRecordVideoModel>.from(current.videos)
        ..addAll(result.videos);

      emit(VideosLoaded(
        videos: merged,
        hasNextPage: result.hasNextPage,
      ));
    } catch (e) {
      // Keep existing items and show error
      emit(VideosError(
        message: e.toString().replaceFirst('Exception: ', ''),
        previousVideos: current.videos,
      ));
    } finally {
      _isFetchingMore = false;
    }
  }

  // ─── Full list – refresh ───────────────────────────────────────────────────

  Future<void> _onRefreshVideos(
      RefreshVideos event,
      Emitter<CareerRecordVideoState> emit,
      ) async {
    final previousVideos = state is VideosLoaded
        ? (state as VideosLoaded).videos
        : <CareerRecordVideoModel>[];

    _currentPage = 1;
    emit(VideosRefreshing(previousVideos));

    try {
      final result = await _repository.fetchVideos(page: 1);
      _currentPage = result.currentPage;
      emit(VideosLoaded(
        videos: result.videos,
        hasNextPage: result.hasNextPage,
      ));
    } catch (e) {
      emit(VideosError(
        message: e.toString().replaceFirst('Exception: ', ''),
        previousVideos: previousVideos,
      ));
    }
  }
}