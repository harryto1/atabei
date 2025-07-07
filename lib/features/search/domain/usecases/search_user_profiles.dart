import 'dart:async';

import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/core/util/firestore_exception.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:atabei/features/profile/domain/repositories/user_profile_repository.dart';

class SearchUserProfilesUseCase implements UseCase<DataState<List<UserProfileEntity>>, SearchUserProfilesParams> {
  final UserProfileRepository _userProfileRepository;

  SearchUserProfilesUseCase(this._userProfileRepository);

  @override
  Future<DataState<List<UserProfileEntity>>> call({SearchUserProfilesParams? params}) {
    if (params == null) {
      throw ArgumentError('SearchUserProfilesParams cannot be null');
    }

    return _userProfileRepository.searchUserProfiles(
      params.query,
      limit: params.limit,
    ).catchError((error) {
      print("📝 UseCase: Exception during user profile search: $error");
      return DataError<List<UserProfileEntity>>(FirestoreException(message: 'Failed to search user profiles: $error'));
    });
  }
}

class SearchUserProfilesParams {
  final String query;
  final int limit;

  SearchUserProfilesParams({
    required this.query,
    this.limit = 20,
  });
}