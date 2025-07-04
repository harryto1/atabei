import 'package:atabei/features/profile/presentation/cubit/profile/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';
import 'package:atabei/features/profile/domain/repositories/user_profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserProfileRepository _userProfileRepository;
  UserProfileEntity? _currentUserProfile;

  ProfileCubit({required UserProfileRepository userProfileRepository})
      : _userProfileRepository = userProfileRepository,
        super(ProfileInitial());

  Future<void> loadProfile(String userId) async {
    print("🔔 Loading profile for user: $userId");
    emit(ProfileLoading());

    try {
      final result = await _userProfileRepository.fetchUserProfile(userId);

      if (result is DataSuccess && result.data != null) {
        _currentUserProfile = result.data as UserProfileEntity;
        print("🔔 Profile loaded successfully for: ${_currentUserProfile!.username}");
        emit(ProfileLoaded(userProfile: _currentUserProfile!));
      } else if (result is DataError) {
        print("🔔 Profile load failed: ${result.error?.message}");
        emit(ProfileError(message: result.error?.message ?? 'Failed to load profile'));
      }
    } catch (e) {
      print("🔔 Exception loading profile: $e");
      emit(ProfileError(message: 'Failed to load profile: $e'));
    }
  }

  Future<void> updateProfile(UserProfileEntity userProfile) async {
    print("🔔 Starting profile update for user: ${userProfile.id}");
    print("🔔 Current cached profile: ${_currentUserProfile?.username}");
    print("🔔 New profile data: ${userProfile.username}");
    
    // Emit updating state with the profile being updated
    emit(ProfileUpdating(currentProfile: userProfile));

    try {
      final result = await _userProfileRepository.updateUserProfile(userProfile);
      
      print("🔔 Update result type: ${result.runtimeType}");

      if (result is DataSuccess) {
        print("🔔 Profile updated successfully in repository");
        
        // Update local cache with the new profile data
        _currentUserProfile = userProfile;
        
        // Emit ProfileLoaded with the updated profile
        emit(ProfileLoaded(userProfile: userProfile));
        
        print("🔔 ProfileLoaded state emitted with updated user: ${userProfile.username}");
        
        // Force refresh from Firestore to ensure data consistency
        await _refreshFromFirestore(userProfile.id);
        
      } else if (result is DataError) {
        print("🔔 Profile update failed: ${result.error?.message}");
        emit(ProfileError(message: result.error?.message ?? 'Failed to update profile'));
      } else {
        print("🔔 Unexpected result type: ${result.runtimeType}");
        emit(ProfileError(message: 'Unexpected error occurred'));
      }
    } catch (e) {
      print("🔔 Exception during profile update: $e");
      emit(ProfileError(message: 'Failed to update profile: $e'));
    }
  }

  // Private method to refresh from Firestore after update
  Future<void> _refreshFromFirestore(String userId) async {
    try {
      print("🔔 Refreshing profile from Firestore for consistency");
      final result = await _userProfileRepository.fetchUserProfile(userId);
      
      if (result is DataSuccess && result.data != null) {
        final freshProfile = result.data as UserProfileEntity;
        _currentUserProfile = freshProfile;
        print("🔔 Profile refreshed from Firestore: ${freshProfile.username}");
        
        // Only emit if the current state is still ProfileLoaded (to avoid overriding error states)
        if (state is ProfileLoaded) {
          emit(ProfileLoaded(userProfile: freshProfile));
        }
      }
    } catch (e) {
      print("🔔 Error refreshing from Firestore: $e");
      // Don't emit error here as the update was successful
    }
  }

  Future<void> refreshProfile(String userId) async {
    print("🔄 Manually refreshing profile for user: $userId");
    await loadProfile(userId);
  }

  // Clear cache when needed
  void clearCache() {
    _currentUserProfile = null;
    emit(ProfileInitial());
  }

  UserProfileEntity? get currentProfile => _currentUserProfile;
}