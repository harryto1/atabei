import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

AppBar appBarWidget() {
  return AppBar(
    title: const Text('Atabei'),
    centerTitle: true,
    actions: [
      BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return TextButton(
              onPressed: () {
                // Navigate to profile page
                Navigator.pushNamed(context, '/profile');
              },
              child: Text(
                state.user.displayName,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            );
          } else {
            return TextButton(
              onPressed: () {
                // Navigate to login page
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Login',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            );
          }
        }
      )
    ],
  );
}