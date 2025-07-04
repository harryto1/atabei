import 'dart:io';

import 'package:atabei/core/resources/data_state.dart';
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
  final String username; 
  
  const LikePost({
    required this.postId,
    required this.userId,
    required this.username, 
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
  final File? imageFile; 
  
  const CreatePost({required this.post, this.imageFile});

  @override
  List<Object?> get props => [post];
}

class DeletePost extends TimelineEvent {
  final String postId; 
  final File? imageFile; 

  const DeletePost({required this.postId, this.imageFile});

  @override
  List<Object?> get props => [postId, imageFile];
}

class RefreshTimeline extends TimelineEvent {
  final int limit;
  
  const RefreshTimeline({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class StreamDataReceived extends TimelineEvent {
  final DataState<List<PostEntity>> dataState;
  
  const StreamDataReceived(this.dataState);
  
  @override
  List<Object?> get props => [dataState];
}

class StreamError extends TimelineEvent {
  final String error;
  
  const StreamError(this.error);
  
  @override
  List<Object?> get props => [error];
}

class StartTimelineStreamFromAuthor extends TimelineEvent {
  final String authorId;
  final int limit;

  const StartTimelineStreamFromAuthor({
    required this.authorId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [authorId, limit];
}

class RefreshTimelineFromAuthor extends TimelineEvent {
  final String authorId;
  final int limit;

  const RefreshTimelineFromAuthor({
    required this.authorId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [authorId, limit];
}

class LoadTimelinePostsFromAuthor extends TimelineEvent {
  final String authorId;
  final int limit;
  final bool isRefresh;

  const LoadTimelinePostsFromAuthor({
    required this.authorId,
    this.limit = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [authorId, limit, isRefresh];
}