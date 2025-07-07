import 'dart:async';

import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/timeline/domain/entities/post_entity.dart';
import 'package:atabei/features/notifications/domain/repositories/notifications_repository.dart';

class GetPostFromNotificationUseCase implements UseCase<DataState<PostEntity>, GetPostFromNotificationParams> {
  final NotificationsRepository _notificationsRepository;

  GetPostFromNotificationUseCase(this._notificationsRepository);

  @override
  Future<DataState<PostEntity>> call({GetPostFromNotificationParams? params}) async {
    if (params == null) {
      throw ArgumentError('GetPostFromNotificationParams cannot be null');
    }

    try {
      print("🔔 UseCase: Getting post from notification: ${params.postId}");
      
      // Add timeout to prevent hanging
      final result = await _notificationsRepository.getPostFromNotification(params.postId)
          .timeout(const Duration(seconds: 10));
      
      if (result is DataSuccess) {
        print("🔔 UseCase: Post retrieved successfully: ${result.data?.id}");
        return result;
      } else if (result is DataError) {
        print("🔔 UseCase: Failed to get post: ${result.error?.message}");
        return result;
      }
      
      return DataError(FirestoreException(message: 'Post not found'));
    } on TimeoutException {
      print("🔔 UseCase: Post fetch timed out");
      return DataError(FirestoreException(message: 'Request timed out'));
    } catch (e) {
      print("🔔 UseCase: Exception getting post: $e");
      return DataError(FirestoreException(message: 'Failed to get post: $e'));
    }
  }
}

class GetPostFromNotificationParams {
  final String postId;

  GetPostFromNotificationParams({required this.postId});
}