import 'dart:async';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_event.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_state.dart';

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
    on<RefreshTimeline>(_onRefreshTimeline);
    on<LikePost>(_onLikePost);
    on<UnlikePost>(_onUnlikePost);
    on<CreatePost>(_onCreatePost);
    on<LoadTimelinePosts>(_onLoadTimelinePosts);
    on<StreamDataReceived>(_onStreamDataReceived); 
  }

  void _onStartTimelineStream(
    StartTimelineStream event,
    Emitter<TimelineState> emit,
  ) async {
    try {
      print('🚀 Starting timeline stream...');
      emit(TimelineLoading());
      
      await _postsStreamSubscription?.cancel();
      
      _postsStreamSubscription = _postsRepository
          .getPostsStream(limit: event.limit)
          .listen(
        (dataState) {
          print('📡 Stream received data: ${dataState.runtimeType}');
          
          // Instead of emitting directly, add an internal event !IMPORTANTTTT
          add(StreamDataReceived(dataState));
        },
        onError: (error) {
          print('❌ Stream listener error: $error');
          add(StreamError(error.toString()));
        },
      );
    } catch (e) {
      print('❌ Stream setup error: $e');
      emit(TimelineError(message: e.toString()));
    }
  }

  void _onStreamDataReceived(
    StreamDataReceived event,
    Emitter<TimelineState> emit,
  ) {
    final dataState = event.dataState;
    
    if (dataState is DataSuccess && dataState.data != null) {
      final newPosts = dataState.data!;
      print('📝 Received ${newPosts.length} posts from stream');
      
      for (var post in newPosts) {
        print('   Post: ${post.username} - ${post.content} - ${post.dateOfPost}');
      }
      
      // ALWAYS update _latestStreamPosts first!
      _latestStreamPosts = newPosts;
      print('📦 Updated _latestStreamPosts with ${_latestStreamPosts.length} posts');
      
      if (_currentPosts.isEmpty) {
        // First load
        print('🔄 First load detected - emitting directly');
        _currentPosts = newPosts;
        emit(TimelineLoaded(
          posts: _currentPosts,
          hasNewPosts: false,
          newPostsCount: 0,
          isStreamActive: true,
        ));
      } else if (newPosts.isNotEmpty && _currentPosts.isNotEmpty) {
        print('🔍 Checking for newer posts...');
        final latestCurrentPost = _currentPosts.first;
        print('   Latest current post date: ${latestCurrentPost.dateOfPost}');
        
        final newerPosts = newPosts.where((post) =>
            post.dateOfPost.isAfter(latestCurrentPost.dateOfPost)).toList();
        
        print('   Found ${newerPosts.length} newer posts');
        
        if (newerPosts.isNotEmpty) {
          print('✨ Showing new posts indicator');
          if (state is TimelineLoaded) {
            final currentState = state as TimelineLoaded;
            emit(currentState.copyWith(
              hasNewPosts: true,
              newPostsCount: newerPosts.length,
              isStreamActive: true,
            ));
          }
        } else {
          print('🔄 Updating existing posts (likes, etc.)');
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
      print('❌ Stream error: ${dataState.error?.message}');
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

  void _onRefreshTimeline(
    RefreshTimeline event,
    Emitter<TimelineState> emit,
  ) async {
    if (_postsStreamSubscription != null) {
      print('🔄 Refreshing from stream data...'); // Add debug
      
      // Use the latest stream data
      _currentPosts = _latestStreamPosts;
      emit(TimelineLoaded(
        posts: _currentPosts,
        hasNewPosts: false,
        newPostsCount: 0,
        isStreamActive: true,
      ));
    } else {
      print('🔄 No stream active, fetching manually...'); // Add debug
      
      emit(TimelineLoading());
      final result = await _postsRepository.getPosts(limit: event.limit);
      
      if (result is DataSuccess) {
        _currentPosts = result.data!;
        emit(TimelineLoaded(
          posts: _currentPosts,
          isStreamActive: false,
        ));
      } else if (result is DataError) {
        emit(TimelineError(message: result.error?.message ?? 'Failed to load posts'));
      }
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
        final createdPost = result.data!;
        print('✅ Post created: ${createdPost.id}');
        
        // Optimistically add the new post immediately
        final updatedPosts = [createdPost, ..._currentPosts];
        _currentPosts = updatedPosts.cast<PostEntity>();
        
        emit(TimelineLoaded(
          posts: updatedPosts.cast<PostEntity>(),
          hasNewPosts: false,
          newPostsCount: 0,
          isStreamActive: _postsStreamSubscription != null,
        ));
        
      } else if (result is DataError) {
        print('❌ Post creation failed: ${result.error?.message}');
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
      // For refresh, keep the stream active but reload data
      if (_postsStreamSubscription != null) {
        if (state is TimelineLoaded) {
          final currentState = state as TimelineLoaded;
          _currentPosts = _latestStreamPosts;
          emit(currentState.copyWith(
            posts: _currentPosts,
            hasNewPosts: false,
            newPostsCount: 0,
            isStreamActive: true,
          ));
        }
      } else {
        add(StartTimelineStream(limit: event.limit));
      }
    } else {
      // Initial load without stream
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