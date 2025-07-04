import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/profile/data/models/user_profile_model.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:atabei/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore; 
  static const String _usersCollection = 'users';

  UserProfileRepositoryImpl({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DataState<UserProfileEntity>> fetchUserProfile(String userId) async {
    try {
      print('📝 Repository: Fetching profile for $userId');
      
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        print('📝 Repository: Profile not found for $userId');
        return DataError<UserProfileEntity>(
          FirestoreException(message: 'User profile not found')
        );
      }
      
      final userProfile = UserProfileModel.fromFirestore(docSnapshot) as UserProfileEntity;
      print('📝 Repository: Profile fetched successfully for ${userProfile.username}');
      
      return DataSuccess<UserProfileEntity>(userProfile);
    } on FirebaseException catch (error) {
      print('📝 Repository: Firebase error: ${error.message}');
      return DataError<UserProfileEntity>(
        FirestoreException.fromFirebaseException(error)
      );
    } catch (e) {
      print('📝 Repository: General error: $e');
      return DataError<UserProfileEntity>(
        FirestoreException(message: e.toString())
      );
    }
  }

  @override
  Future<DataState<void>> updateUserProfile(UserProfileEntity userProfile) async {
    try {
      print('📝 Repository: Updating profile for ${userProfile.id}');
      print('📝 Repository: New username: ${userProfile.username}');
      print('📝 Repository: New bio: ${userProfile.bio}');
      print('📝 Repository: New location: ${userProfile.location}');
      
      final docRef = _firestore.collection(_usersCollection).doc(userProfile.id);
      
      // Create the data map manually to ensure it's correct
      final profileData = {
        'id': userProfile.id,
        'fcmToken': userProfile.fcmToken,
        'username': userProfile.username,
        'bio': userProfile.bio,
        'location': userProfile.location,
        'pathToProfilePicture': userProfile.pathToProfilePicture,
        'dateJoined': userProfile.dateJoined.toIso8601String(),
        'isPrivate': userProfile.isPrivate,
        'lastUpdated': DateTime.now().toIso8601String(), 
      };
      
      await docRef.set(profileData, SetOptions(merge: true));
      
      print('📝 Repository: Profile updated successfully in Firestore');
      
      // Verify the update by reading it back
      final updatedDoc = await docRef.get();
      if (updatedDoc.exists) {
        print('📝 Repository: Verified - document exists with username: ${updatedDoc.data()?['username']}');
      } else {
        print('📝 Repository: Warning - document does not exist after update');
      }
      
      return DataSuccess<void>(null);
    } on FirebaseException catch (error) {
      print('📝 Repository: Firebase error updating profile: ${error.message}');
      return DataError<void>(
        FirestoreException.fromFirebaseException(error)
      );
    } catch (e) {
      print('📝 Repository: General error updating profile: $e');
      return DataError<void>(
        FirestoreException(message: e.toString())
      );
    }
  }

  @override
  Future<DataState<void>> deleteUserProfile(String userId) async {
    try {
      print('📝 Repository: Deleting profile for $userId');
      
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      await docRef.delete();
      
      print('📝 Repository: Profile deleted successfully');
      return DataSuccess<void>(null);
    } on FirebaseException catch (error) {
      print('📝 Repository: Firebase error deleting profile: ${error.message}');
      return DataError<void>(
        FirestoreException.fromFirebaseException(error)
      );
    } catch (e) {
      print('📝 Repository: General error deleting profile: $e');
      return DataError<void>(
        FirestoreException(message: e.toString())
      );
    }
  }
}