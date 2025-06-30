import 'package:atabei/features/auth/data/repositories/auth_repository.dart';
import 'package:atabei/features/auth/domain/repositories/auth_repository.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(firebaseAuth: sl<FirebaseAuth>()));
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(authRepository: sl<AuthRepository>())); 
}