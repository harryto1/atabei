import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override 
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName; 

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthSignOutRequested extends AuthEvent {}

class StreamDataReceived extends AuthEvent {
  final DataState<UserEntity> user; 
  
  const StreamDataReceived(this.user);
  
  @override
  List<Object?> get props => [user];
}

class StreamError extends AuthEvent {
  final String error;
  
  const StreamError(this.error);
  
  @override
  List<Object?> get props => [error];
}