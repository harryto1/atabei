import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.fcmToken,
    required super.username,
    super.bio,
    super.pathToProfilePicture,
    super.location,
    super.birthdate,
    required super.dateJoined,
    required super.isPrivate,    
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfileModel(
      id: doc.id,
      fcmToken: data['fcmToken'] as String,
      username: data['username'] as String,
      bio: data['bio'] as String?,
      pathToProfilePicture: data['pathToProfilePicture'] as String?,
      location: data['location'] as String?,
      birthdate: _convertToDateTime(data['birthdate']),
      dateJoined: _convertToDateTime(data['dateJoined']),
      isPrivate: data['isPrivate'] as bool? ?? false,
    );
  }

  // Helper method to convert various date formats to DateTime
  static DateTime _convertToDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      // Note: We don't include 'id' here since Firestore handles document IDs separately
      'fcmToken': fcmToken,
      'username': username,
      'bio': bio,
      'pathToProfilePicture': pathToProfilePicture,
      'location': location,
      'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
      'dateJoined': Timestamp.fromDate(dateJoined),
      'isPrivate': isPrivate,
    }; 
  }

  static UserProfileModel fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      fcmToken: entity.fcmToken,
      username: entity.username,
      bio: entity.bio,
      pathToProfilePicture: entity.pathToProfilePicture,
      location: entity.location,
      birthdate: entity.birthdate,
      dateJoined: entity.dateJoined,
      isPrivate: entity.isPrivate,
    );
  }

  @override
  UserProfileModel copyWith({
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
    return UserProfileModel(
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
  
}