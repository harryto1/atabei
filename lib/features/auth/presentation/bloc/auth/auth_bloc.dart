import 'dart:async';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/services/notification_service.dart';
import 'package:atabei/dependencies.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:atabei/features/auth/domain/usecases/get_auth_state_stream.dart';
import 'package:atabei/features/auth/domain/usecases/get_current_user.dart';
import 'package:atabei/features/auth/domain/usecases/sign_in.dart';
import 'package:atabei/features/auth/domain/usecases/sign_out.dart';
import 'package:atabei/features/auth/domain/usecases/sign_up.dart';
import 'package:atabei/features/auth/domain/usecases/verify_current_user.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStateStreamUseCase _getAuthStateStreamUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final SignUpUseCase _signUpUseCase;
  final VerifyCurrentUserUseCase _verifyCurrentUserUseCase;
  StreamSubscription? _authStateSubscription; 

  AuthBloc() : 
    _getAuthStateStreamUseCase = sl<GetAuthStateStreamUseCase>(),
    _getCurrentUserUseCase = sl<GetCurrentUserUseCase>(),
    _signInUseCase = sl<SignInUseCase>(),
    _signOutUseCase = sl<SignOutUseCase>(),
    _signUpUseCase = sl<SignUpUseCase>(),
    _verifyCurrentUserUseCase = sl<VerifyCurrentUserUseCase>(),
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
    _authStateSubscription = _getAuthStateStreamUseCase().listen(
      (dataState) { 
        add(StreamDataReceived(dataState));
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
    
  final userResult = await _getCurrentUserUseCase();
  
    if (userResult is DataSuccess && userResult.data != null) {
      try {
        print('🔍 Verifying current user at startup...');
        final userExists = await _verifyCurrentUserUseCase();         
        if (userExists is DataSuccess<bool> && userExists.data == true) {
          print('✅ User verified at startup');
          emit(AuthAuthenticated(user: userResult.data!));
        } else {
          print('❌ User no longer exists, cleaning up...');
          await _signOutUseCase();
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        print('❌ Startup user verification failed: $e');
        await _signOutUseCase();
        emit(AuthUnauthenticated());
      }
    } else {
      print('❌ No user found at startup');
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
  ) async {
    final userResult = await _getCurrentUserUseCase();
    
    if (userResult is DataSuccess && userResult.data != null) {
      emit(AuthAuthenticated(user: userResult.data!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signInUseCase(
      params: SignInParams(
        email: event.email,
        password: event.password,
      ),
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
    
    final result = await _signUpUseCase(
      params: SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
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
    
    final result = await _signOutUseCase();

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