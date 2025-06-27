import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TimelineEvent extends Equatable {
  const TimelineEvent();

  @override
  List<Object?> get props => [];
}

class LoadTimelinePosts extends TimelineEvent {
  final int limit;
  final bool isRefresh;
  
  const LoadTimelinePosts({
    this.limit = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [limit, isRefresh];
}

class StartTimelineStream extends TimelineEvent {
  final int limit;
  
  const StartTimelineStream({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

class StopTimelineStream extends TimelineEvent {}

class LoadNewPosts extends TimelineEvent {
  const LoadNewPosts();

  @override
  List<Object?> get props => [];
}

class LikePost extends TimelineEvent {
  final String postId;
  final String userId;
  
  const LikePost({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

class UnlikePost extends TimelineEvent {
  final String postId;
  final String userId;
  
  const UnlikePost({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}

class CreatePost extends TimelineEvent {
  final PostEntity post;
  
  const CreatePost({required this.post});

  @override
  List<Object?> get props => [post];
}