import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStateStreamUseCase implements StreamUseCase<DataState<UserEntity?>, NoParams> {
  final AuthRepository _authRepository;

  GetAuthStateStreamUseCase(this._authRepository);

  @override
  Stream<DataState<UserEntity?>> call({NoParams? params}) {
    try {
      print("🔐 UseCase: Starting auth state stream");
      
      return _authRepository.authStateChanges
          .map((user) {
            if (user != null) {
              print("🔐 UseCase: Auth state changed - user logged in: ${user.email}");
              return DataSuccess<UserEntity?>(user);
            } else {
              print("🔐 UseCase: Auth state changed - user logged out");
              return const DataSuccess<UserEntity?>(null);
            }
          })
          .handleError((error) {
            print("🔐 UseCase: Auth state stream error: $error");
            return DataError<UserEntity?>(AuthException(message: 'Auth state stream error: $error'));
          });
    } catch (e) {
      print("🔐 UseCase: Exception starting auth state stream: $e");
      throw Exception('Failed to start auth state stream: $e');
    }
  }
}