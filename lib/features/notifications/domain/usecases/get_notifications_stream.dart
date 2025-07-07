import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/notifications/domain/entities/likes_entity.dart';
import 'package:atabei/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsStreamUseCase implements StreamUseCase<DataState<List<LikesEntity>>, GetNotificationsStreamParams> {
  final NotificationsRepository _notificationsRepository;

  GetNotificationsStreamUseCase(this._notificationsRepository);

  @override
  Stream<DataState<List<LikesEntity>>> call({GetNotificationsStreamParams? params}) {
    if (params == null) {
      throw ArgumentError('GetNotificationsStreamParams cannot be null');
    }

    try {
      print("🔔 UseCase: Starting notifications stream for user: ${params.userId}");
      
      return _notificationsRepository.getNotificationsStream(
        params.notificationId,
        params.userId,
        limit: params.limit,
      ).handleError((error) {
        print("🔔 UseCase: Stream error: $error");
        return Stream.value(
          DataError(
            FirestoreException(message: 'Failed to start notifications stream: $error'),
          )
        ); 
      });
    } catch (e) {
      print("🔔 UseCase: Exception starting notifications stream: $e");
      return Stream.value(
        DataError(
          FirestoreException(message: 'Failed to start notifications stream: $e'),
        ),
      );
    }
  }
}

class GetNotificationsStreamParams {
  final String notificationId;
  final String userId;
  final int limit;

  GetNotificationsStreamParams({
    required this.notificationId,
    required this.userId,
    this.limit = 20,
  });
}