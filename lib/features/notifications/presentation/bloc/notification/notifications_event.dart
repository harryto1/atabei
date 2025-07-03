import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final String notificationId; 
  final String userId;
  final int limit;
  final bool isRefresh; 

  const LoadNotifications({
    required this.notificationId,
    required this.userId,
    this.isRefresh = false,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [notificationId, userId, limit, isRefresh];
}

class StartNotificationsStream extends NotificationsEvent {
  final String notificationId; 
  final String userId;
  final int limit;

  const StartNotificationsStream({
    required this.notificationId,
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [notificationId, userId, limit];
}

class StopNotificationsStream extends NotificationsEvent {
  const StopNotificationsStream();

  @override
  List<Object?> get props => [];
}

class LoadNewNotifications extends NotificationsEvent {
  const LoadNewNotifications();

  @override
  List<Object?> get props => [];
}

class RefreshNotifications extends NotificationsEvent {
  final String notificationId; 
  final String userId;
  final int limit;

  const RefreshNotifications({
    required this.notificationId,
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [notificationId, userId, limit];
}

class StreamDataReceived extends NotificationsEvent {
  final DataState<List<LikesEntity>> dataState;

  const StreamDataReceived(this.dataState);

  @override
  List<Object?> get props => [dataState];
}

class StreamError extends NotificationsEvent {
  final String error;

  const StreamError({
    required this.error,
  });

  @override
  List<Object?> get props => [error];
}

