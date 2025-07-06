import 'dart:async';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/services/notification_service.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository; 
  StreamSubscription? _authStateSubscription; 

  AuthBloc({required AuthRepository authRepository}) : 
    _authRepository = authRepository,
    super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<StreamDataReceived>(_onStreamDataReceived);
    on<AuthInitializeRequested>(_onAuthInitializeRequested);
    
    // Start listening to auth state changes
    _startAuthStateListener();
  }
  
  void _startAuthStateListener() {
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          add(StreamDataReceived(DataSuccess(user)));
        } else {
          add(StreamDataReceived(DataError(AuthException(message: 'User is null'))));
        }
      },
      onError: (error) {
        print('Auth stream error: $error');
        add(StreamDataReceived(DataError(AuthException(message: error.toString()))));
      },
    );
  }

  void _onAuthInitializeRequested(
    AuthInitializeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    print('🚀 Initializing app auth state...');
    
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      try {
        print('🔍 Verifying current user at startup...');
        final userExists = await _authRepository.verifyCurrentUser();         
        if (userExists) {
          print('✅ User verified at startup');
          emit(AuthAuthenticated(user: user));
        } else {
          print('❌ User no longer exists, cleaning up...');
          await _authRepository.signOut();
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        print('❌ Startup user verification failed: $e');
        await _authRepository.signOut();
        emit(AuthUnauthenticated());
      }
    } else {
      print('ℹ️ No user at startup');
      emit(AuthUnauthenticated());
    }
  }
  
  void _onStreamDataReceived(StreamDataReceived event, Emitter<AuthState> emit) {
    final userState = event.user;
    if (userState is DataSuccess<UserEntity?>) {
      final user = userState.data;
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else if (userState is DataError) {
      emit(AuthError(message: userState.error?.message ?? 'Unknown error'));
    }
  }  

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _authRepository.signInWithEmailAndPassword(
      event.email,
      event.password,
    );

    if (result is DataSuccess) {
      // Don't emit here, let the stream handle it
      print('✅ Sign in successful');

      NotificationService.saveFcmToken().then((_) {
        print('✅ FCM token saved successfully');
      }).catchError((error) {
        print('❌ Failed to save FCM token: $error');
      });

      

      emit(AuthAuthenticated(user: result.data!));

    } else if (result is DataError) {
      emit(AuthError(message: result.error?.message ?? 'Sign in failed'));
    }
  }

  void _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    print('📝 Attempting sign up...');
    
    final result = await _authRepository.createUserWithEmailAndPassword(
      event.email,
      event.password,
      event.displayName,
    );

    if (result is DataSuccess) {
      print('✅ Sign up successful - letting stream handle state');
      // Don't emit here either, let the stream handle it

      emit(AuthAuthenticated(user: result.data!));

    } else if (result is DataError) {
      print('❌ Sign up failed: ${result.error?.message}');
      emit(AuthError(message: result.error?.message ?? 'Sign up failed'));
    }
  }

  void _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _authRepository.signOut();

    if (result is DataSuccess) {
      print('✅ Sign out successful');
    }
    
    if (result is DataError) {
      emit(AuthError(message: result.error?.message ?? 'Sign out failed'));
    }

  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}