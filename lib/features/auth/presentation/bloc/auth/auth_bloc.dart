import 'dart:async';
import 'package:atabei/core/resources/data_state.dart';
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
        add(StreamDataReceived(DataError(AuthException(message: error.toString()))));
      },
    );
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
    } else if (result is DataError) {
      emit(AuthError(message: result.error?.message ?? 'Sign in failed'));
    }
  }

  void _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _authRepository.createUserWithEmailAndPassword(
      event.email,
      event.password,
      event.displayName 
    );

    if (result is DataSuccess) {
      // Don't emit here, let the stream handle it
      print('✅ Sign up successful');
    } else if (result is DataError) {
      emit(AuthError(message: result.error?.message ?? 'Sign up failed'));
    }
  }

  void _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _authRepository.signOut();
    
    if (result is DataError) {
      emit(AuthError(message: result.error?.message ?? 'Sign out failed'));
    }
    // Success case handled by stream
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}