import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';

class VerifyCurrentUserUseCase implements UseCase<DataState<bool>, NoParams> {
  final AuthRepository _authRepository;

  VerifyCurrentUserUseCase(this._authRepository);

  @override
  Future<DataState<bool>> call({NoParams? params}) async {
    try {
      print("🔐 UseCase: Verifying current user");
      
      final isValid = await _authRepository.verifyCurrentUser();
      
      if (isValid) {
        print("🔐 UseCase: User verification successful");
      } else {
        print("🔐 UseCase: User verification failed");
      }
      
      return DataSuccess(isValid);
    } catch (e) {
      print("🔐 UseCase: Exception verifying user: $e");
      return DataError(AuthException(message: 'Failed to verify user: $e'));
    }
  }
}