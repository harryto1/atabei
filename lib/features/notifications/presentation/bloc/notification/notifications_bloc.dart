import 'dart:async';

import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:atabei/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:atabei/features/notifications/presentation/bloc/notification/notifications_event.dart';
import 'package:atabei/features/notifications/presentation/bloc/notification/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _notificationsRepository;
  StreamSubscription? _notificationsStreamSubscription;
  List<LikesEntity> _currentLikes = []; 
  List<LikesEntity> _latestStreamLikes = []; 

  NotificationsBloc({required NotificationsRepository notificationsRepository}) : 
  _notificationsRepository = notificationsRepository, super(NotificationsInitial()) {
    on<StartNotificationsStream>(_onStartNotificationsStream);
    on<StopNotificationsStream>(_onStopNotificationsStream);
    on<LoadNewNotifications>(_onLoadNewNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<LoadNotifications>(_onLoadNotifications);
    on<StreamDataReceived>(_onStreamDataReceived);
  }

  void _onStartNotificationsStream(
    StartNotificationsStream event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      print('🔔 Starting notifications stream for user: ${event.userId}');
      await _notificationsStreamSubscription?.cancel();

      _notificationsStreamSubscription = _notificationsRepository.getNotificationsStream(
        event.notificationId,
        event.userId,
        limit: event.limit,
      ).listen(
        (dataState) {
          print('🔔 Notifications stream data received: $dataState');
          add(StreamDataReceived(dataState));
        },
        onError: (error) {
          print('🔔 Notifications stream error: $error');
          add(StreamError(error: error.toString()));
        },
      ); 
    } catch (e) {
      print('🔔 Error starting notifications stream: $e');
      add(StreamError(error: e.toString()));
    }
  }

  void _onStreamDataReceived(
    StreamDataReceived event,
    Emitter<NotificationsState> emit, 
  ) {
    final dataState = event.dataState;

    if (dataState is DataSuccess && dataState.data != null) {
      final newLikes = dataState.data!; 
      print('🔔 Stream data received: ${newLikes.length} likes');

      _latestStreamLikes = newLikes;
      print('🔔 Latest stream likes: ${_latestStreamLikes.length}');

      if (_currentLikes.isEmpty) {
        print("🔔 First load detected - emitting directly");
        _currentLikes = newLikes; 
        emit(NotificationsLoaded(
          likes: _currentLikes, 
          hasNewLikes: false,
          newLikesCount: 0,
          isStreamActive: true,
        ));
      } else if (newLikes.isNotEmpty && _currentLikes.isNotEmpty) {
        print("🔔 New likes detected - checking for new likes");
        final latestCurrentLikes = _currentLikes.first; 
        print("🔔 Latest current like: ${latestCurrentLikes.timestamp}");
        final newerLikes = newLikes.where((like) =>
          like.timestamp.isAfter(latestCurrentLikes.timestamp)).toList();
        print(" Found ${newerLikes.length} newer likes");

        if (newerLikes.isNotEmpty) {
          print("✨ Showing new likes indicator");
          if (state is NotificationsLoaded) {
            final currentState = state as NotificationsLoaded;
            emit(currentState.copyWith(
              hasNewLikes: true,
              newLikesCount: newerLikes.length,
              isStreamActive: true,
            )); 
          }
        } else {
          print("🔔 No new likes detected");
          if (state is NotificationsLoaded) {
            final currentState = state as NotificationsLoaded;
            emit(currentState.copyWith(
              likes: _currentLikes,
              isStreamActive: true,
            ));
          }
        }
      }
    } else if (dataState is DataError) {
      print('🔔 Stream error received: ${dataState.error?.message}');
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        emit(currentState.copyWith(
          error: dataState.error?.message ?? 'Unknown error',
          isStreamActive: true,
        ));
      } else {
        emit(NotificationsError(message: dataState.error?.message ?? 'Unknown error'));
      }
    } else {
      print('🔔 Unknown data state received: $dataState');
    }
  }

  void _onStopNotificationsStream(
    StopNotificationsStream event,
    Emitter<NotificationsState> emit,
  ) {
    _notificationsStreamSubscription?.cancel();
    _notificationsStreamSubscription = null;

    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(currentState.copyWith(
        isStreamActive: false
      )); 
    }
  }

  void _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (_notificationsStreamSubscription != null) {
      print('🔄 Refreshing notifications stream');

      _currentLikes = _latestStreamLikes;
      emit(NotificationsLoaded(
        likes: _currentLikes,
        hasNewLikes: false,
        newLikesCount: 0,
        isStreamActive: true,
      ));
    } else {
      print('🔄 No stream active, fetching manually...'); // Add debug

      emit(NotificationsLoading());
      final result = await _notificationsRepository.getNotifications(
        event.notificationId,
        event.userId,
        limit: event.limit,
      );

      if (result is DataSuccess) {
        _currentLikes = result.data!; 
        emit(NotificationsLoaded(
          likes: _currentLikes, 
          isStreamActive: false,
        )); 
      } else if (result is DataError) {
        emit(NotificationsError(
          message: result.error?.message ?? 'Unknown error',
        ));
      }
    }
  }

  void _onLoadNewNotifications(
    LoadNewNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    _currentLikes = _latestStreamLikes; 
    emit(NotificationsLoaded(
      likes: _currentLikes, 
      hasNewLikes: false,
      newLikesCount: 0,
      isStreamActive: _notificationsStreamSubscription != null, 
    ));
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event.isRefresh) {
      // For refresh, keep the stream active but reload data
      if (_notificationsStreamSubscription != null) {
        final currentState = state as NotificationsLoaded;
        _currentLikes = _latestStreamLikes; 
        emit(currentState.copyWith(
          likes: _currentLikes,
          hasNewLikes: false,
          newLikesCount: 0,
          isStreamActive: true,
        ));
      } else {
        add(StartNotificationsStream(notificationId: event.notificationId, userId: event.userId, limit: event.limit));

      }
    } else {
      emit(NotificationsLoading());

      final result = await _notificationsRepository.getNotifications(
        event.notificationId,
        event.userId,
        limit: event.limit,
      );

      if (result is DataSuccess) {
        _currentLikes = result.data!;
        emit(NotificationsLoaded(
          likes: _currentLikes, 
          isStreamActive: false, 
        ));
      } else if (result is DataError) {
        emit(NotificationsError(
          message: result.error?.message ?? 'Failed to load notifications',
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _notificationsStreamSubscription?.cancel();
    return super.close();
  }

}