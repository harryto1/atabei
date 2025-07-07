import 'package:atabei/core/resources/data_state.dart';
import 'package:atabei/core/usecases/usecase.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<DataState<void>> call({NoParams? params}) {
    return _authRepository.signOut();
  }
}