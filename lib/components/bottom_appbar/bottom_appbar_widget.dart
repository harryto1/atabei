import 'package:flutter/material.dart';

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
            Navigator.pushReplacementNamed(context, '/notifications');
          },
        ),
        IconButton(
          icon: Icon(
            tabIndex == 3 ? Icons.account_circle_rounded : Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/profile');
          },
        ),
      ],
    ),
  );
}