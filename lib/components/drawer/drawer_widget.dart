import 'package:atabei/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:atabei/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Drawer drawerWidget(BuildContext context) {
  return Drawer(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Container(
                padding: EdgeInsets.only(top: 20), 
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: state.user.pathToProfilePicture != null
                              ? NetworkImage(state.user.pathToProfilePicture!)
                              : null,
                          radius: 30,
                          child: state.user.pathToProfilePicture == null
                              ? Text(state.user.displayName.substring(0, 1).toUpperCase(), style: Theme.of(context).textTheme.titleLarge,)
                              : null,
                        ),
                        title: Text(state.user.displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                        subtitle: Text(state.user.email),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: ListTile(
                        minTileHeight: 75,
                        leading: Icon(Icons.person),
                        title: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: ListTile(
                        minTileHeight: 75,
                        leading: Icon(Icons.bookmark),
                        title: Text(
                          'Bookmarks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/bookmarks');
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                    ), 
                    Container(
                      alignment: Alignment.center,
                      child: ListTile(
                        minTileHeight: 75,
                        leading: Icon(Icons.settings),
                        title: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: ListTile(
                        minTileHeight: 75,
                        leading: Icon(Icons.logout, color: Colors.redAccent),
                        title: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          context.read<AuthBloc>().add(AuthSignOutRequested());
                          Navigator.pop(context); // Close the drawer after signing out
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login to see your profile', style: Theme.of(context).textTheme.titleMedium),
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              );
            }
          },
        )
      ); 
}