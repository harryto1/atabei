import 'dart:async';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/timeline/domain/repositories/local_image_repository.dart';
import 'package:atabei/features/timeline/domain/repositories/post_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_event.dart';
import 'package:atabei/features/timeline/presentation/bloc/timeline/timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final PostRepository _postsRepository;
  final LocalImageRepository _localImageRepository; 
  StreamSubscription? _postsStreamSubscription;
  List<PostEntity> _currentPosts = [];
  List<PostEntity> _latestStreamPosts = [];

  TimelineBloc({required PostRepository postsRepository, required LocalImageRepository localImageRepository})
      : _postsRepository = postsRepository, 
        _localImageRepository = localImageRepository, 
        super(TimelineInitial()) {
    
    on<StartTimelineStream>(_onStartTimelineStream);
    on<StopTimelineStream>(_onStopTimelineStream);
    on<RefreshTimeline>(_onRefreshTimeline);
    on<LikePost>(_onLikePost);
    on<UnlikePost>(_onUnlikePost);
    on<CreatePost>(_onCreatePost);
    on<DeletePost>(_onDeletePost);
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

      var eventPost = event.post; 

      if (event.imageFile != null) {
        final imageResult = await _localImageRepository.uploadPostImage(event.imageFile!, event.post.id);
        if (imageResult is DataSuccess) {
          // Update the post with the image path
          eventPost = event.post.copyWith(pathToImage: imageResult.data);
        } else if (imageResult is DataError) {
          print('❌ Image upload failed: ${imageResult.error?.message}');
          emit(currentState.copyWith(
            error: imageResult.error?.message ?? 'Failed to upload image',
          ));
          return; // Exit early if image upload fails
        }
      }
    
      final result = await _postsRepository.createPost(eventPost);
      
      if (result is DataSuccess) {
        final createdPost = result.data!;
        print('✅ Post created: ${createdPost.id}');

        _currentPosts = _latestStreamPosts; 

        emit(TimelineLoaded(
          posts: _currentPosts,
          isStreamActive: true,
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

  void _onDeletePost(
    DeletePost event,
    Emitter<TimelineState> emit,
  ) async {
    if (state is TimelineLoaded) {
      final currentState = state as TimelineLoaded;
      emit(TimelinePostDeleting(postId: event.postId, imageFile: event.imageFile));
      print('🗑️ Deleting post with ID: ${event.postId}');

      try {
        // Delete the post from the repository
        final result1 = await _postsRepository.deletePost(event.postId);

        if (result1 is DataError) {
          emit(currentState.copyWith(
            error: result1.error?.message ?? 'Failed to delete post',
          ));
          return; // Exit early if post deletion fails
        } else if (result1 is DataSuccess) {
          print('✅ Post deleted successfully');
        }

        if (event.imageFile == null) {
          print('No image file provided, skipping local deletion');
          // Remove the post from the current posts list
          _currentPosts.removeWhere((post) => post.id == event.postId);
          emit(currentState.copyWith(
            posts: _currentPosts,
            isStreamActive: true,
          ));
          return;
        }

        final result2 = await _localImageRepository.deletePostImage(event.imageFile?.path ?? '');

        if (result2 is DataError) {
          print('❌ Local image deletion failed: ${result2.error?.message}');
        } else {
          print('✅ Local image deleted successfully');
        }
        
        // Remove the post from the current posts list
        _currentPosts.removeWhere((post) => post.id == event.postId);

        print('📝 Updated current posts after deletion: ${_currentPosts.length} posts remaining');
        
        // Emit updated state
        emit(currentState.copyWith(
          posts: _currentPosts,
          isStreamActive: true,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          error: e.toString(),
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