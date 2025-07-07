import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<DataState<UserEntity?>, NoParams> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity?>> call({NoParams? params}) async {
    try {
      print("🔐 UseCase: Getting current user");
      
      final user = _authRepository.getCurrentUser();
      
      if (user != null) {
        print("🔐 UseCase: Current user found: ${user.email}");
        return DataSuccess(user);
      } else {
        print("🔐 UseCase: No current user found");
        return const DataSuccess(null);
      }
    } catch (e) {
      print("🔐 UseCase: Exception getting current user: $e");
      return DataError(AuthException(message: 'Failed to get current user: $e'));
    }
  }
}