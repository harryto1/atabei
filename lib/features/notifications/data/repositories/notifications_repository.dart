import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/notifications/data/models/likes_model.dart';
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:atabei/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final FirebaseFirestore _firestore; 
  static const String _likesCollection = 'likes';
  static const String _postsCollection = 'post';

  NotificationsRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;



  @override
  Future<DataState<List<LikesEntity>>> fetchNotifications() {
    throw UnimplementedError("fetchNotifications is not implemented yet");
  }

  @override
  Stream<DataState<List<LikesEntity>>> getNotificationsStream(String notificationId, String userId, {limit = 20}) async* {
    try {
      // Get all posts created by the user
      final postsQuery = await _firestore
          .collection(_postsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final postIds = postsQuery.docs.map((doc) => doc.id).toList();

      if (postIds.isEmpty) {
        yield DataSuccess<List<LikesEntity>>([]);
        return;
      }

      // Listen for likes on those posts
      yield* _firestore
          .collection(_likesCollection)
          .where('postId', whereIn: postIds)
          .where('userId', isNotEqualTo: userId) // Exclude likes by the user themselves
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map<DataState<List<LikesEntity>>>((querySnapshot) {
            try {
              final likesEntities = querySnapshot.docs
                  .map((doc) => LikesModel.fromFirestore(doc) as LikesEntity)
                  .toList();
              return DataSuccess<List<LikesEntity>>(likesEntities);
            } catch (e) {
              return DataError(FirestoreException(message: e.toString()));
            }
          }).handleError((error) {
            if (error is FirebaseException) {
              return DataError(FirestoreException.fromFirebaseException(error));
            }
            return DataError(FirestoreException(message: error.toString()));
          });
    } catch (e) {
      yield DataError(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<DataState<List<LikesEntity>>> getNotifications(String notificationId, String userId, {int limit = 20}) async {
    try {
      // Get all posts created by the user
      final postsQuery = await _firestore
          .collection(_postsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final postIds = postsQuery.docs.map((doc) => doc.id).toList();

      if (postIds.isEmpty) {
        return DataSuccess<List<LikesEntity>>([]);
      }

      // Fetch likes on those posts
      final likesQuery = await _firestore
          .collection(_likesCollection)
          .where('postId', whereIn: postIds)
          .where('userId', isNotEqualTo: userId) // Exclude likes by the user themselves
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final likesEntities = likesQuery.docs
          .map((doc) => LikesModel.fromFirestore(doc) as LikesEntity)
          .toList();

      return DataSuccess<List<LikesEntity>>(likesEntities);
    } catch (e) {
      return DataError(FirestoreException(message: e.toString()));
    }
  }
  
}