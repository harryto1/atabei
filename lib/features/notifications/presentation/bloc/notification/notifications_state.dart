import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<LikesEntity> likes;
  final bool hasNewLikes;
  final int newLikesCount;
  final bool isStreamActive; 
  final String? error;

  const NotificationsLoaded({
    required this.likes,
    this.hasNewLikes = false,
    this.newLikesCount = 0,
    this.isStreamActive = false,
    this.error,
  });

  NotificationsLoaded copyWith({
    List<LikesEntity>? likes,
    bool? hasNewLikes,
    int? newLikesCount,
    bool? isStreamActive,
    String? error,
  }) {
    return NotificationsLoaded(
      likes: likes ?? this.likes,
      hasNewLikes: hasNewLikes ?? this.hasNewLikes,
      newLikesCount: newLikesCount ?? this.newLikesCount,
      isStreamActive: isStreamActive ?? this.isStreamActive,
      error: error,
    );
  }

  @override
  List<Object?> get props => [likes, hasNewLikes, newLikesCount, isStreamActive, error];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationsEmpty extends NotificationsState {
  final String message;

  const NotificationsEmpty({this.message = "No notifications available."});

  @override
  List<Object?> get props => [message];
}
