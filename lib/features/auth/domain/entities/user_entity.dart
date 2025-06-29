import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid; 
  final String email; 
  final String displayName; 
  final String? pathToProfilePicture; 
  final DateTime dateJoined;
  final bool isEmailVerified; 

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.pathToProfilePicture,
    required this.dateJoined,
    required this.isEmailVerified,
  }); 

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    pathToProfilePicture,
    dateJoined,
    isEmailVerified,
  ];
}