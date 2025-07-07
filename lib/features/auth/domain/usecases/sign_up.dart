import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/auth/domain/entities/user_entity.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<DataState<UserEntity>, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({SignUpParams? params}) {
    if (params == null) {
      throw ArgumentError('SignUpParams cannot be null');
    }

    return _authRepository.createUserWithEmailAndPassword(
      params.email.trim(),
      params.password,
      params.displayName.trim(),
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String displayName;

  SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
}