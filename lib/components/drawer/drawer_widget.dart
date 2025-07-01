import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Drawer drawerWidget(BuildContext context) {
  return Drawer(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: state.user.pathToProfilePicture != null
                      ? NetworkImage(state.user.pathToProfilePicture!)
                      : null,
                  child: state.user.pathToProfilePicture == null
                      ? Text(state.user.displayName.substring(0, 1).toUpperCase())
                      : null,
                ),
                title: Text(state.user.displayName),
                subtitle: Text(state.user.email),
              );
            } else {
              return ListTile(
                title: const Text('Login to see your profile'),
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              );
            }
          },
        )
      ); 
}