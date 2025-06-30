import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> signInWithEmailAndPassword(String email, String password);
  Future<DataState<UserEntity>> createUserWithEmailAndPassword(String email, String password, String displayName);
  Future<DataState<void>> signOut(); 
  Future<bool> verifyCurrentUser(); 
  UserEntity? getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}