import '../../data/models/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final bool hasUnread;
  final bool hasMore;
  final int currentPage;

  NotificationLoaded(
      this.notifications, {
        this.hasUnread = false,
        this.hasMore = false,
        this.currentPage = 1,
      });
}

class NotificationLoadingMore extends NotificationState {
  final List<NotificationModel> notifications;
  final bool hasUnread;
  final int currentPage;

  NotificationLoadingMore(
      this.notifications, {
        required this.hasUnread,
        required this.currentPage,
      });
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}