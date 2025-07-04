import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

AppBar appBarWidget(BuildContext context) {
  return AppBar(
    title: Text('Atabei', style: Theme.of(context).appBarTheme.titleTextStyle), 
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    actionsPadding: EdgeInsets.symmetric(horizontal: 16), 
    leading: Builder(
      builder: (context) {
        return IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Scaffold.of(context).openDrawer(); 
          },
        );
      },
    ), 
    actions: [
      BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return GestureDetector(
              onTap:() {
                Navigator.pushReplacementNamed(context, '/profile');
              },
              child: CircleAvatar(
                    radius: 20,
                    backgroundImage: state.user.pathToProfilePicture != null
                        ? NetworkImage(state.user.pathToProfilePicture!)
                        : null,
                    child: state.user.pathToProfilePicture == null
                        ? Text(state.user.displayName.substring(0, 1).toUpperCase())
                        : null,
                  ),
            ); 
          } else {
            return TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(
                'Login',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }
        }
      )
    ],
  );
}