import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/profile/domain/repositories/user_profile_repository.dart';

class DeleteUserProfileUseCase implements UseCase<DataState<void>, DeleteUserProfileParams> {
  final UserProfileRepository _userProfileRepository;

  DeleteUserProfileUseCase(this._userProfileRepository);

  @override
  Future<DataState<void>> call({DeleteUserProfileParams? params}) async {
    if (params == null) {
      throw ArgumentError('DeleteUserProfileParams cannot be null');
    }

    try {
      print("📝 UseCase: Deleting profile for user: ${params.userId}");
      
      final result = await _userProfileRepository.deleteUserProfile(params.userId);
      
      if (result is DataSuccess) {
        print("📝 UseCase: Profile deletion successful");
      } else if (result is DataError) {
        print("📝 UseCase: Profile deletion failed: ${result.error?.message}");
      }
      
      return result;
    } catch (e) {
      print("📝 UseCase: Exception during profile deletion: $e");
      return DataError(FirestoreException(message: 'Failed to delete profile: $e'));
    }
  }
}

class DeleteUserProfileParams {
  final String userId;

  DeleteUserProfileParams({required this.userId});
}