import 'dart:async';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_event.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_state.dart';
import 'package:atabei/features/timeline/data/models/post_model.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final PostRepository _postsRepository;
  StreamSubscription? _postsStreamSubscription;
  List<PostEntity> _currentPosts = [];
  List<PostEntity> _latestStreamPosts = [];

  TimelineBloc({required PostRepository postsRepository})
      : _postsRepository = postsRepository,
        super(TimelineInitial()) {
    
    on<StartTimelineStream>(_onStartTimelineStream);
    on<StopTimelineStream>(_onStopTimelineStream);
    on<LoadNewPosts>(_onLoadNewPosts);
    on<LikePost>(_onLikePost);
    on<UnlikePost>(_onUnlikePost);
    on<CreatePost>(_onCreatePost);
    on<LoadTimelinePosts>(_onLoadTimelinePosts);
  }

  void _onStartTimelineStream(
    StartTimelineStream event,
    Emitter<TimelineState> emit,
  ) async {
    try {
      emit(TimelineLoading());
      
      await _postsStreamSubscription?.cancel();
      
      _postsStreamSubscription = _postsRepository
          .getPostsStream(limit: event.limit)
          .listen(
        (dataState) {
          if (dataState is DataSuccess && dataState.data != null) {
            final newPosts = dataState.data!;
            _latestStreamPosts = newPosts;
            
            if (_currentPosts.isEmpty) {
              // First load
              _currentPosts = newPosts;
              add(const LoadNewPosts());
            } else if (newPosts.isNotEmpty && _currentPosts.isNotEmpty) {
              // Check for newer posts
              final latestCurrentPost = _currentPosts.first;
              final newerPosts = newPosts.where((post) =>
                  post.dateOfPost.isAfter(latestCurrentPost.dateOfPost)).toList();
              
              if (newerPosts.isNotEmpty) {
                // New posts available - show indicator
                if (state is TimelineLoaded) {
                  final currentState = state as TimelineLoaded;
                  emit(currentState.copyWith(
                    hasNewPosts: true,
                    newPostsCount: newerPosts.length,
                    isStreamActive: true,
                  ));
                }
              } else {
                // Update existing posts (likes, comments, etc.)
                _currentPosts = newPosts;
                if (state is TimelineLoaded) {
                  final currentState = state as TimelineLoaded;
                  emit(currentState.copyWith(
                    posts: _currentPosts,
                    isStreamActive: true,
                  ));
                }
              }
            }
          } else if (dataState is DataError) {
            if (state is TimelineLoaded) {
              final currentState = state as TimelineLoaded;
              emit(currentState.copyWith(
                error: dataState.error?.message ?? 'Unknown error',
                isStreamActive: true,
              ));
            } else {
              emit(TimelineError(
                message: dataState.error?.message ?? 'Unknown error',
              ));
            }
          }
        },
        onError: (error) {
          if (state is TimelineLoaded) {
            final currentState = state as TimelineLoaded;
            emit(currentState.copyWith(
              error: error.toString(),
              isStreamActive: false,
            ));
          } else {
            emit(TimelineError(message: error.toString()));
          }
        },
      );
    } catch (e) {
      emit(TimelineError(message: e.toString()));
    }
  }

  void _onStopTimelineStream(
    StopTimelineStream event,
    Emitter<TimelineState> emit,
  ) {
    _postsStreamSubscription?.cancel();
    _postsStreamSubscription = null;
    
    if (state is TimelineLoaded) {
      final currentState = state as TimelineLoaded;
      emit(currentState.copyWith(isStreamActive: false));
    }
  }

  void _onLoadNewPosts(
    LoadNewPosts event,
    Emitter<TimelineState> emit,
  ) {
    _currentPosts = _latestStreamPosts;
    emit(TimelineLoaded(
      posts: _currentPosts,
      hasNewPosts: false,
      newPostsCount: 0,
      isStreamActive: _postsStreamSubscription != null,
    ));
  }

  void _onLikePost(
    LikePost event,
    Emitter<TimelineState> emit,
  ) async {
    if (state is TimelineLoaded) {
      final currentState = state as TimelineLoaded;
      emit(TimelinePostLiking(
        postId: event.postId,
        posts: currentState.posts,
      ));

      final result = await _postsRepository.likePost(event.postId, event.userId);
      
      if (result is DataSuccess) {
        // Update will come through the stream
        emit(currentState);
      } else if (result is DataError) {
        emit(currentState.copyWith(
          error: result.error?.message ?? 'Failed to like post',
        ));
      }
    }
  }

  void _onUnlikePost(
    UnlikePost event,
    Emitter<TimelineState> emit,
  ) async {
    if (state is TimelineLoaded) {
      final currentState = state as TimelineLoaded;
      emit(TimelinePostLiking(
        postId: event.postId,
        posts: currentState.posts,
      ));

      final result = await _postsRepository.unlikePost(event.postId, event.userId);
      
      if (result is DataSuccess) {
        // Update will come through the stream
        emit(currentState);
      } else if (result is DataError) {
        emit(currentState.copyWith(
          error: result.error?.message ?? 'Failed to unlike post',
        ));
      }
    }
  }

  void _onCreatePost(
    CreatePost event,
    Emitter<TimelineState> emit,
  ) async {
    if (state is TimelineLoaded) {
      final currentState = state as TimelineLoaded;
      emit(TimelinePostCreating(posts: currentState.posts));

      final result = await _postsRepository.createPost(event.post);
      
      if (result is DataSuccess) {
        // New post will come through the stream
        emit(currentState);
      } else if (result is DataError) {
        emit(currentState.copyWith(
          error: result.error?.message ?? 'Failed to create post',
        ));
      }
    }
  }

  void _onLoadTimelinePosts(
    LoadTimelinePosts event,
    Emitter<TimelineState> emit,
  ) async {
    if (event.isRefresh) {
      // Restart the stream for refresh
      add(StartTimelineStream(limit: event.limit));
    } else {
      emit(TimelineLoading());
      
      final result = await _postsRepository.getPosts(limit: event.limit);
      
      if (result is DataSuccess) {
        _currentPosts = result.data!;
        emit(TimelineLoaded(
          posts: _currentPosts,
          isStreamActive: false,
        ));
      } else if (result is DataError) {
        emit(TimelineError(
          message: result.error?.message ?? 'Failed to load posts',
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _postsStreamSubscription?.cancel();
    return super.close();
  }
}