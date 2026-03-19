import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/career_record_video/career_record_video_bloc.dart';
import 'package:careers/bloc/career_record_video/career_record_video_event.dart';
import 'package:careers/bloc/career_record_video/career_record_video_state.dart';
import 'package:careers/data/models/career_record_video_model.dart';
import 'package:careers/screens/home/widgets/youtube_player_page.dart';

class CareerRecordVideosPage extends StatefulWidget {
  const CareerRecordVideosPage({super.key});

  @override
  State<CareerRecordVideosPage> createState() => _CareerRecordVideosPageState();
}

class _CareerRecordVideosPageState extends State<CareerRecordVideosPage> {
  final ScrollController _scrollController = ScrollController();

  CareerRecordVideoBloc get _bloc => context.read<CareerRecordVideoBloc>();

  @override
  void initState() {
    super.initState();
    // Always start fresh when this page opens.
    _bloc.add(FetchVideosFirstPage());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Triggers FetchVideosNextPage when within 250 px of the list bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 250) {
      _bloc.add(FetchVideosNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Career Guidance Classes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<CareerRecordVideoBloc, CareerRecordVideoState>(
        builder: (context, state) {
          // ── Full-screen loading ────────────────────────────────────
          if (state is VideosLoading ||
              state is CareerRecordVideoInitial ||
              state is HomeVideosLoading ||
              state is HomeVideosLoaded) {
            // HomeVideosLoaded means the full-list fetch hasn't started yet —
            // show spinner until FetchVideosFirstPage emits VideosLoaded.
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal1),
            );
          }

          // ── Refreshing with stale data ─────────────────────────────
          if (state is VideosRefreshing) {
            return Stack(
              children: [
                _VideoList(
                  videos: state.previousVideos,
                  isLoadingMore: false,
                  scrollController: _scrollController,
                ),
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33FFFFFF),
                    child: Center(
                      child:
                      CircularProgressIndicator(color: AppColors.teal1),
                    ),
                  ),
                ),
              ],
            );
          }

          // ── Error ──────────────────────────────────────────────────
          if (state is VideosError) {
            if (state.previousVideos.isEmpty) {
              return _FullPageError(
                message: state.message,
                onRetry: () => _bloc.add(FetchVideosFirstPage()),
              );
            }
            return Column(
              children: [
                _ErrorBanner(
                  message: state.message,
                  onRetry: () => _bloc.add(FetchVideosFirstPage()),
                ),
                Expanded(
                  child: _VideoList(
                    videos: state.previousVideos,
                    isLoadingMore: false,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            );
          }

          // ── Loaded ─────────────────────────────────────────────────
          if (state is VideosLoaded) {
            if (state.videos.isEmpty) {
              return const Center(child: Text('No videos available'));
            }

            return RefreshIndicator(
              color: AppColors.teal1,
              onRefresh: () async {
                _bloc.add(RefreshVideos());
                await _bloc.stream.firstWhere(
                      (s) => s is VideosLoaded || s is VideosError,
                );
              },
              child: _VideoList(
                videos: state.videos,
                isLoadingMore: state.isLoadingMore,
                scrollController: _scrollController,
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// ── Video list with optional bottom loader ────────────────────────────────────
class _VideoList extends StatelessWidget {
  final List<CareerRecordVideoModel> videos;
  final bool isLoadingMore;
  final ScrollController scrollController;

  const _VideoList({
    required this.videos,
    required this.isLoadingMore,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(4),
        vertical: Responsive.h(2),
      ),
      itemCount: videos.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(1.5)),
      itemBuilder: (context, index) {
        if (index == videos.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.teal1,
                strokeWidth: 2.5,
              ),
            ),
          );
        }
        return _VideoListTile(video: videos[index]);
      },
    );
  }
}

// ── Single video row ──────────────────────────────────────────────────────────
class _VideoListTile extends StatelessWidget {
  final CareerRecordVideoModel video;
  const _VideoListTile({required this.video});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(Responsive.w(4)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YoutubePlayerPage(
              videoId: video.videoId,
              title: video.title,
              about: video.about,
              duration: video.duration,
              creator: video.creator,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(Responsive.w(4)),
        splashColor: AppColors.teal1.withOpacity(0.1),
        highlightColor: AppColors.teal1.withOpacity(0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Responsive.w(4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal1.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Responsive.w(4)),
                  bottomLeft: Radius.circular(Responsive.w(4)),
                ),
                child: Image.network(
                  'https://img.youtube.com/vi/${video.videoId}/mqdefault.jpg',
                  width: Responsive.w(35),
                  height: Responsive.h(10),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: Responsive.w(35),
                    height: Responsive.h(10),
                    color: AppColors.teal1.withOpacity(0.1),
                    child: Icon(
                      Icons.play_circle_outline,
                      color: AppColors.teal1,
                      size: Responsive.w(8),
                    ),
                  ),
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(3),
                    vertical: Responsive.h(1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          fontSize: Responsive.sp(13),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.h(0.5)),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: Responsive.w(3.5),
                              color: AppColors.textSecondary),
                          SizedBox(width: Responsive.w(1)),
                          Expanded(
                            child: Text(
                              video.creator,
                              style: TextStyle(
                                fontSize: Responsive.sp(11),
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(0.3)),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: Responsive.w(3.5),
                              color: AppColors.teal1),
                          SizedBox(width: Responsive.w(1)),
                          Text(
                            video.duration,
                            style: TextStyle(
                              fontSize: Responsive.sp(11),
                              color: AppColors.teal1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Play icon
              Padding(
                padding: EdgeInsets.only(right: Responsive.w(3)),
                child: Container(
                  padding: EdgeInsets.all(Responsive.w(2)),
                  decoration: BoxDecoration(
                    color: AppColors.teal1.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.teal1,
                    size: Responsive.w(5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Full-page error screen ────────────────────────────────────────────────────
class _FullPageError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _FullPageError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: Responsive.w(14), color: AppColors.textSecondary),
            SizedBox(height: Responsive.h(2)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Responsive.sp(13),
                  color: AppColors.textSecondary),
            ),
            SizedBox(height: Responsive.h(2)),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inline error banner ───────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error.withOpacity(0.1),
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(4), vertical: Responsive.h(1)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          SizedBox(width: Responsive.w(2)),
          Expanded(
            child: Text(
              message,
              style:
              const TextStyle(fontSize: 12, color: AppColors.error),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.teal1,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}