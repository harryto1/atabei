// This is a separate class from User_Entity.
// This class is an entity from the Users Collection in Firestore. 

import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id; 
  final String fcmToken; 
  final String username; 
  final String? bio; 
  final String? pathToProfilePicture;
  final String? location; 
  final DateTime? birthdate;
  final DateTime dateJoined;
  final bool isPrivate;

  const UserProfileEntity ({
    required this.id,
    required this.fcmToken,
    required this.username,
    this.bio,
    this.pathToProfilePicture,
    this.location,
    this.birthdate,
    required this.dateJoined,
    required this.isPrivate,
  });

  UserProfileEntity copyWith({
    String? id,
    String? fcmToken,
    String? username,
    String? bio,
    String? pathToProfilePicture,
    String? location,
    DateTime? birthdate,
    DateTime? dateJoined,
    bool? isPrivate,
  }) {
    return UserProfileEntity (
      id: id ?? this.id,
      fcmToken: fcmToken ?? this.fcmToken,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      pathToProfilePicture: pathToProfilePicture ?? this.pathToProfilePicture,
      location: location ?? this.location,
      birthdate: birthdate ?? this.birthdate,
      dateJoined: dateJoined ?? this.dateJoined,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    fcmToken,
    username,
    bio,
    pathToProfilePicture,
    location,
    birthdate,
    dateJoined,
    isPrivate,
  ]; 
}