import '../../data/models/career_record_video_model.dart';

abstract class CareerRecordVideoState {
  const CareerRecordVideoState();
}

class CareerRecordVideoInitial extends CareerRecordVideoState {
  const CareerRecordVideoInitial();
}

// ─── Home list states ─────────────────────────────────────────────────────────

class HomeVideosLoading extends CareerRecordVideoState {
  const HomeVideosLoading();
}

class HomeVideosLoaded extends CareerRecordVideoState {
  final List<CareerRecordVideoModel> videos;
  HomeVideosLoaded(this.videos);
}

class HomeVideosError extends CareerRecordVideoState {
  final String message;
  HomeVideosError(this.message);
}

// ─── Full paginated list states ───────────────────────────────────────────────

class VideosLoading extends CareerRecordVideoState {
  const VideosLoading();
}

/// Emitted while loading page 1 but stale data is still available (refresh).
class VideosRefreshing extends CareerRecordVideoState {
  final List<CareerRecordVideoModel> previousVideos;
  VideosRefreshing(this.previousVideos);
}

class VideosLoaded extends CareerRecordVideoState {
  final List<CareerRecordVideoModel> videos;
  final bool isLoadingMore;
  final bool hasNextPage;

  VideosLoaded({
    required this.videos,
    this.isLoadingMore = false,
    required this.hasNextPage,
  });

  VideosLoaded copyWith({
    List<CareerRecordVideoModel>? videos,
    bool? isLoadingMore,
    bool? hasNextPage,
  }) {
    return VideosLoaded(
      videos: videos ?? this.videos,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class VideosError extends CareerRecordVideoState {
  final String message;
  /// Stale data shown behind an error banner (may be empty).
  final List<CareerRecordVideoModel> previousVideos;

  VideosError({
    required this.message,
    this.previousVideos = const [],
  });
}