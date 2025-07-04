import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {
  final UserProfileEntity currentProfile;

  const ProfileUpdating({required this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity userProfile;

  const ProfileLoaded({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}