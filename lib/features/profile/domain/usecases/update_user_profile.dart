import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:atabei/features/profile/domain/repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase implements UseCase<DataState<void>, UpdateUserProfileParams> {
  final UserProfileRepository _userProfileRepository;

  UpdateUserProfileUseCase(this._userProfileRepository);

  @override
  Future<DataState<void>> call({UpdateUserProfileParams? params}) async {
    if (params == null) {
      throw ArgumentError('UpdateUserProfileParams cannot be null');
    }

    try {
      print("📝 UseCase: Updating profile for ${params.userProfile.username}");
      
      final result = await _userProfileRepository.updateUserProfile(params.userProfile);
      
      if (result is DataSuccess) {
        print("📝 UseCase: Profile update successful");
      } else if (result is DataError) {
        print("📝 UseCase: Profile update failed: ${result.error?.message}");
      }
      
      return result;
    } catch (e) {
      print("📝 UseCase: Exception during profile update: $e");
      return DataError(FirestoreException(message: 'Failed to update profile: $e'));
    }
  }
}

class UpdateUserProfileParams {
  final UserProfileEntity userProfile;

  UpdateUserProfileParams({required this.userProfile});
}