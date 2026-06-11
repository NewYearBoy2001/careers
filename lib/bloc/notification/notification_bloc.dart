import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:careers/data/models/notification_model.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  final AuthLocalStorage _storage;

  NotificationBloc(this._repository, this._storage)
      : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetch);
    on<FetchMoreNotifications>(_onFetchMore);
    on<MarkNotificationsRead>(_onMarkRead);
  }

  Future<void> _onFetch(
      FetchNotifications event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      final result = await _repository.getNotifications(page: 1);
      final notifications = result['notifications'] as List<NotificationModel>;
      final hasMore = result['hasMore'] as bool;
      final currentPage = result['currentPage'] as int;
      final lastSeenId = await _storage.getLastSeenNotificationId();
      final hasUnread = notifications.isNotEmpty &&
          notifications.first.id > lastSeenId;
      emit(NotificationLoaded(
        notifications,
        hasUnread: hasUnread,
        hasMore: hasMore,
        currentPage: currentPage,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onFetchMore(
      FetchMoreNotifications event,
      Emitter<NotificationState> emit,
      ) async {
    final current = state;
    if (current is! NotificationLoaded || !current.hasMore) return;

    emit(NotificationLoadingMore(
      current.notifications,
      hasUnread: current.hasUnread,
      currentPage: current.currentPage,
    ));

    try {
      final nextPage = current.currentPage + 1;
      final result = await _repository.getNotifications(page: nextPage);
      final newNotifications = result['notifications'] as List<NotificationModel>;
      final hasMore = result['hasMore'] as bool;

      emit(NotificationLoaded(
        [...current.notifications, ...newNotifications],
        hasUnread: current.hasUnread,
        hasMore: hasMore,
        currentPage: nextPage,
      ));
    } catch (e) {
      // On error restore previous state
      emit(NotificationLoaded(
        current.notifications,
        hasUnread: current.hasUnread,
        hasMore: current.hasMore,
        currentPage: current.currentPage,
      ));
    }
  }

  Future<void> _onMarkRead(
      MarkNotificationsRead event,
      Emitter<NotificationState> emit,
      ) async {
    final current = state;
    if (current is NotificationLoaded && current.notifications.isNotEmpty) {
      await _storage.saveLastSeenNotificationId(
          current.notifications.first.id);
      emit(NotificationLoaded(
        current.notifications,
        hasUnread: false,
        hasMore: current.hasMore,
        currentPage: current.currentPage,
      ));
    }
  }
}