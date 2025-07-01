import 'dart:io';

import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TimelineState extends Equatable {
  const TimelineState();

  @override
  List<Object?> get props => [];
}

class TimelineInitial extends TimelineState {}

class TimelineLoading extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final List<PostEntity> posts;
  final bool hasNewPosts;
  final int newPostsCount;
  final bool isStreamActive;
  final String? error;
  
  const TimelineLoaded({
    required this.posts,
    this.hasNewPosts = false,
    this.newPostsCount = 0,
    this.isStreamActive = false,
    this.error,
  });

  TimelineLoaded copyWith({
    List<PostEntity>? posts,
    bool? hasNewPosts,
    int? newPostsCount,
    bool? isStreamActive,
    String? error,
  }) {
    return TimelineLoaded(
      posts: posts ?? this.posts,
      hasNewPosts: hasNewPosts ?? this.hasNewPosts,
      newPostsCount: newPostsCount ?? this.newPostsCount,
      isStreamActive: isStreamActive ?? this.isStreamActive,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    hasNewPosts,
    newPostsCount,
    isStreamActive,
    error,
  ];
}

class TimelineError extends TimelineState {
  final String message;
  
  const TimelineError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TimelinePostLiking extends TimelineState {
  final String postId;
  final List<PostEntity> posts;
  
  const TimelinePostLiking({
    required this.postId,
    required this.posts,
  });

  @override
  List<Object?> get props => [postId, posts];
}

class TimelinePostCreating extends TimelineState {
  final List<PostEntity> posts;
  
  const TimelinePostCreating({required this.posts});

  @override
  List<Object?> get props => [posts];
}

class TimelinePostDeleting extends TimelineState {
  final String postId; 
  final File? imageFile; 

  const TimelinePostDeleting({
    required this.postId,
    this.imageFile,
  });

  @override
  List<Object?> get props => [postId, imageFile];
}