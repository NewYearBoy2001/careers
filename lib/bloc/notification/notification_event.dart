abstract class NotificationEvent {}

class FetchNotifications extends NotificationEvent {
  final int page;
  FetchNotifications({this.page = 1});
}

class FetchMoreNotifications extends NotificationEvent {} // ADD

class MarkNotificationsRead extends NotificationEvent {}