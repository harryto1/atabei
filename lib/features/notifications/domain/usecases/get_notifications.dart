import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:atabei/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase implements UseCase<DataState<List<LikesEntity>>, GetNotificationsParams> {
  final NotificationsRepository _notificationsRepository;

  GetNotificationsUseCase(this._notificationsRepository);

  @override
  Future<DataState<List<LikesEntity>>> call({GetNotificationsParams? params}) async {
    if (params == null) {
      throw ArgumentError('GetNotificationsParams cannot be null');
    }

    try {
      print("🔔 UseCase: Getting notifications for user: ${params.userId}");
      
      final result = await _notificationsRepository.getNotifications(
        params.notificationId,
        params.userId,
        limit: params.limit,
      );
      
      if (result is DataSuccess) {
        final notifications = result.data ?? [];
        print("🔔 UseCase: Retrieved ${notifications.length} notifications");
        return DataSuccess(notifications);
      } else if (result is DataError) {
        print("🔔 UseCase: Failed to get notifications: ${result.error?.message}");
        return result;
      }
      
      return const DataSuccess(<LikesEntity>[]);
    } catch (e) {
      print("🔔 UseCase: Exception getting notifications: $e");
      return DataError(FirestoreException(message: 'Failed to get notifications: $e'));
    }
  }
}

class GetNotificationsParams {
  final String notificationId;
  final String userId;
  final int limit;

  GetNotificationsParams({
    required this.notificationId,
    required this.userId,
    this.limit = 20,
  });
}