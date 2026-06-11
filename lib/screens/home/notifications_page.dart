import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:careers/constants/app_colors.dart';
import 'package:careers/constants/app_text_styles.dart';
import 'package:careers/utils/responsive/responsive.dart';
import 'package:careers/bloc/notification/notification_bloc.dart';
import 'package:careers/bloc/notification/notification_event.dart';
import 'package:careers/bloc/notification/notification_state.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:careers/data/models/notification_model.dart';
import 'package:careers/screens/admission/widgets/user_info_dialog.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController(); // ADD

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotifications());
    _scrollController.addListener(_onScroll); // ADD
  }

  // ADD
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<NotificationBloc>().state;
      if (state is NotificationLoaded && state.hasMore) {
        context.read<NotificationBloc>().add(FetchMoreNotifications());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ADD
    super.dispose();
  }

  Future<void> _onCardTap(NotificationModel n) async {
    final storage = AuthLocalStorage();

    if (Platform.isIOS) {
      final storedFlag = await storage.getStoredFlag();
      if (storedFlag == '1') {
        final profile = await storage.getCachedProfile();
        final userId = profile['user_id'] ?? '';
        if (!mounted) return;
        context.push('/college-details', extra: <String, String>{
          'id': n.collegeId,
          'user_id': userId,
        });
        return;
      }
    }

    final phone = await storage.getPhone();
    final name = await storage.getUserName();
    final hasData = phone != null &&
        phone.isNotEmpty &&
        name != null &&
        name.isNotEmpty;

    if (!mounted) return;

    if (!hasData) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.45),
        useSafeArea: false,
        builder: (_) => const UserInfoDialog(),
      );
      if (result != true || !mounted) return;
    }

    final profile = await storage.getCachedProfile();
    final userId = profile['user_id'] ?? '';

    if (!mounted) return;
    context.push('/college-details', extra: <String, String>{
      'id': n.collegeId,
      'user_id': userId,
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocConsumer<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is NotificationLoaded &&
                    state.notifications.isNotEmpty &&
                    state.hasUnread) {  // ADD this guard
                  context.read<NotificationBloc>().add(MarkNotificationsRead());
                }
              },
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is NotificationError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            color: AppColors.textSecondary,
                            size: Responsive.w(12)),
                        SizedBox(height: Responsive.h(1)),
                        Text(state.message,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: Responsive.sp(14)),
                            textAlign: TextAlign.center),
                        SizedBox(height: Responsive.h(1.5)),
                        ElevatedButton(
                          onPressed: () => context
                              .read<NotificationBloc>()
                              .add(FetchNotifications()),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                // ADD this before the NotificationLoaded check
                if (state is NotificationLoadingMore) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<NotificationBloc>().add(FetchNotifications());
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.all(Responsive.w(4)),
                      itemCount: state.notifications.length + 1,
                      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(1.2)),
                      itemBuilder: (context, index) {
                        if (index == state.notifications.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }
                        final n = state.notifications[index];
                        return _NotificationCard(
                          notification: n,
                          onTap: () => _onCardTap(n),
                        );
                      },
                    ),
                  );
                }
                if (state is NotificationLoaded) {
                  if (state.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: Responsive.w(15),
                              color: AppColors.textSecondary),
                          SizedBox(height: Responsive.h(1.5)),
                          Text('No notifications yet',
                              style: AppTextStyles.sectionTitle(
                                  fontSize: Responsive.sp(16))),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context
                          .read<NotificationBloc>()
                          .add(FetchNotifications());
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.all(Responsive.w(4)),
                      itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          SizedBox(height: Responsive.h(1.2)),
                      itemBuilder: (context, index) {
                        if (index == state.notifications.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(2)),
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }
                        final n = state.notifications[index];
                        return _NotificationCard(
                          notification: n,
                          onTap: () => _onCardTap(n),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMiddle,
            AppColors.headerGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.w(2),
        MediaQuery.of(context).padding.top + Responsive.h(1),
        Responsive.w(4),
        Responsive.h(2),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Text(
            'Notifications',
            style: AppTextStyles.pageTitle(fontSize: Responsive.sp(20)),
          ),
        ],
      ),
    );
  }
}

// ── Notification card (styled like CollegeCard + time_ago badge) ──────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Responsive.w(2.5)),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Responsive.w(2.5)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.w(2.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row + rating ──────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        n.college,
                        style: AppTextStyles.cardTitle(
                            fontSize: Responsive.sp(15)),
                      ),
                    ),
                    SizedBox(width: Responsive.w(2)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(2),
                        vertical: Responsive.h(0.5),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(Responsive.w(1.8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.primary,
                              size: Responsive.sp(14)),
                          SizedBox(width: Responsive.w(1)),
                          Text(
                            n.rating,
                            style: TextStyle(
                              fontSize: Responsive.sp(12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.h(0.6)),

                // ── Location ────────────────────────────────────────────
                if (n.location.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: Responsive.sp(14),
                          color: AppColors.textSecondary),
                      SizedBox(width: Responsive.w(1)),
                      Expanded(
                        child: Text(
                          n.location,
                          style: TextStyle(
                            fontSize: Responsive.sp(12),
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: Responsive.h(0.7)),

                // ── Courses ─────────────────────────────────────────────
                if (n.courses.isNotEmpty)
                  Text(
                    n.courses,
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                SizedBox(height: Responsive.h(0.9)),

                // ── Bottom row: time_ago + View Details ─────────────────
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(2.5),
                        vertical: Responsive.h(0.4),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: Responsive.sp(11),
                              color: AppColors.teal1),
                          SizedBox(width: Responsive.w(1)),
                          Text(
                            n.timeAgo,
                            style: TextStyle(
                              fontSize: Responsive.sp(11),
                              fontWeight: FontWeight.w600,
                              color: AppColors.teal1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: Responsive.sp(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: Responsive.w(1)),
                    Icon(Icons.arrow_forward,
                        size: Responsive.sp(14), color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}