import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';

abstract class NotificationsRepository {
  /// Fetches notifications from the repository.
  ///
  /// Returns a list of notifications.
  Future<DataState<List<LikesEntity>>> fetchNotifications();
  // LikesEntity will be changed to NotificationEntity in the future.
  // Right now its just LikesEntity because its the only one implemented. 

  Stream<DataState<List<LikesEntity>>> getNotificationsStream(String notificationId, String userId, {int limit = 20});

  Future<DataState<List<LikesEntity>>> getNotifications(String notificationId, String userId, {int limit = 20});

  Future<DataState<PostEntity>> getPostFromNotification(String postId);
  
}