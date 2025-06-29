import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends UserEntity{
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.pathToProfilePicture,
    required super.dateJoined,
    required super.isEmailVerified,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      pathToProfilePicture: user.photoURL,
      dateJoined: user.metadata.creationTime ?? DateTime.now(),
      isEmailVerified: user.emailVerified,
    ); 
  }

}