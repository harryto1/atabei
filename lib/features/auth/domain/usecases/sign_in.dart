import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase implements UseCase<DataState<UserEntity>, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({SignInParams? params}) {
    if (params == null) {
      throw ArgumentError('SignInParams cannot be null');
    }
    return _authRepository.signInWithEmailAndPassword(
      params.email.trim(),
      params.password,
    );
  }
}

class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });
}