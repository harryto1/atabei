import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

BottomAppBar bottomAppBarWidget(BuildContext context, int tabIndex) {
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
          ),
          onPressed: () {
            // Navigate to search page
          },
        ),
        IconButton(
          icon: Icon(
            tabIndex == 2 ? Icons.notifications : Icons.notifications_none,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthUnauthenticated) {
              Navigator.pushNamed(context, '/login');
            } else {
              Navigator.pushReplacementNamed(context, '/notifications');
            }
          },
        ),
        IconButton(
          icon: Icon(
            tabIndex == 3 ? Icons.account_circle_rounded : Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthUnauthenticated) {
              Navigator.pushNamed(context, '/login');
            } else {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
        ),
      ],
    ),
  );
}