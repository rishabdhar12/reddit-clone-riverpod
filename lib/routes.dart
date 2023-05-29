// logged out route
import 'package:flutter/material.dart';
import 'package:reddit_clone_provider/features/auth/screens/login_screen.dart';
import 'package:reddit_clone_provider/features/community/screens/add_moderators.dart';
import 'package:reddit_clone_provider/features/community/screens/community_screen.dart';
import 'package:reddit_clone_provider/features/community/screens/create_community_screen.dart';
import 'package:reddit_clone_provider/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone_provider/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone_provider/features/home/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: LoginScreen(),
      ),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateCommunity()),
  '/r/:name': (route) => MaterialPage(
        child: CommunityScreen(name: route.pathParameters['name']!),
      ), // dynamic route (r/community_name)
  '/mod-tools/:name': (route) => MaterialPage(
        child: ModToolsScreen(
          name: route.pathParameters['name']!,
        ),
      ),
  '/edit-community/:name': (route) => MaterialPage(
        child: EditCommunityScreen(
          name: route.pathParameters['name']!,
        ),
      ),
  '/add-mods/:name': (route) => MaterialPage(
        child: AddModsScreen(
          name: route.pathParameters['name']!,
        ),
      ),
});
