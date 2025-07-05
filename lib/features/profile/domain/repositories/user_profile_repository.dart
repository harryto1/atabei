import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<DataState<UserProfileEntity>> fetchUserProfile(String userId);
  Future<DataState<void>> updateUserProfile(UserProfileEntity userProfile);
  Future<DataState<void>> deleteUserProfile(String userId);
  // For search feature
  Future<DataState<List<UserProfileEntity>>> searchUserProfiles(
    String query, {
    int limit = 20,
  });
}