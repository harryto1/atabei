import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget bottomAppBarWidget(BuildContext context, int tabIndex) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, authState) {
      return BottomAppBar(
        height: 60,
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                tabIndex == 0 ? Icons.home : Icons.home_outlined,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            IconButton(
              icon: Icon(
                tabIndex == 1 ? Icons.search_rounded : Icons.search_outlined,
                color: Theme.of(context).colorScheme.onPrimary,
                fill: tabIndex == 1 ? 1 : 0,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/search');
              },
            ),
            IconButton(
              icon: Icon(
                tabIndex == 2 ? Icons.notifications : Icons.notifications_none,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                if (authState is AuthAuthenticated) {
                  Navigator.pushReplacementNamed(context, '/notifications');
                } else {
                  Navigator.pushNamed(context, '/login'); 
                }
              },
            ),
            IconButton(
              icon: Icon(
                tabIndex == 3 ? Icons.account_circle_rounded : Icons.account_circle_outlined,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                if (authState is AuthAuthenticated) {
                  Navigator.pushReplacementNamed(context, '/profile');
                } else {
                  Navigator.pushNamed(context, '/login'); 
                }
              },
            ),
          ],
        ),
      );
    },
  );
}