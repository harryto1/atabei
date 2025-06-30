import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/auth/data/models/user_model.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth; 

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        return UserModel.fromFirebaseUser(user);
      } else {
        return null; 
      }
    });

  }

  @override
  Future<DataState<UserEntity>> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null) {
        // Update the user's display name
        await user.updateProfile(displayName: displayName);
        final userModel = UserModel.fromFirebaseUser(user);
        return DataSuccess<UserEntity>(userModel as UserEntity);
      } else {
        return DataError(AuthException(message: "User creation failed"));
      }
    } on FirebaseAuthException catch (e) {
      return DataError(AuthException(message: e.message ?? 'An error occurred during user creation'));
    } catch (e) {
      return DataError(AuthException(message: e.toString()));
    }
  }

  @override
  UserEntity? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user); 
    } else {
      return null; 
    }
  }

  @override
  Future<DataState<UserEntity>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel.fromFirebaseUser(user);
        return DataSuccess<UserEntity>(userModel);
      } else {
        return DataError(AuthException(message: "User not found")); 
      }
    } on FirebaseAuthException catch (e) {
      return DataError(AuthException(message: e.message ?? 'An error occurred during sign-in'));
    } catch (e) {
      return DataError(AuthException(message: e.toString()));
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const DataSuccess<void>(null);
    } catch (e) {
      return DataError(AuthException(message: e.toString()));
    }
  } 

  @override
  Future<bool> verifyCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      
      // Try to reload user data
      await user.reload();
      
      // Check if user still exists
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      print('User verification failed: $e');
      return false;
    }
  }
}