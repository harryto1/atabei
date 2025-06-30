import 'package:atabei/config/routes/app_router.dart';
import 'package:atabei/config/theme/app_theme.dart';
import 'package:atabei/features/auth/data/repositories/auth_repository.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(appRouter: AppRouter()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});

  final AppRouter appRouter; 

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authRepository: AuthRepositoryImpl(firebaseAuth: FirebaseAuth.instance))
        ..add(AuthInitializeRequested()), 
      child: MaterialApp(
        title: 'Atabei',
        theme: AppTheme.lightTheme, 
        darkTheme: AppTheme.darkTheme, 
        themeMode: ThemeMode.system,
        onGenerateRoute: appRouter.onGenerateRoute, 
      ),
    );
  }
}