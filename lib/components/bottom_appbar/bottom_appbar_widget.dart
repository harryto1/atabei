import 'package:flutter/material.dart';

BottomAppBar bottomAppBarWidget(BuildContext context) {
  return BottomAppBar(
        height: 60,
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/'); 
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                // Handle search button press
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                // Handle notifications button press
                Navigator.pushReplacementNamed(context, '/notifications');
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                // Handle profile button press
              },
            ),
          ],
        ),
      ); 
}