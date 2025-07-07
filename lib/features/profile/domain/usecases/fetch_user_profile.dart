import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:atabei/features/profile/domain/repositories/user_profile_repository.dart';

class FetchUserProfileUseCase implements UseCase<DataState<UserProfileEntity>, FetchUserProfileParams> {
  final UserProfileRepository _userProfileRepository;

  FetchUserProfileUseCase(this._userProfileRepository);

  @override
  Future<DataState<UserProfileEntity>> call({FetchUserProfileParams? params}) {
    if (params == null) {
      throw ArgumentError('FetchUserProfileParams cannot be null');
    }
    
    return _userProfileRepository.fetchUserProfile(params.userId);
  }
}

class FetchUserProfileParams {
  final String userId;

  FetchUserProfileParams({required this.userId});
}