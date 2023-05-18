// logged out route
import 'package:flutter/material.dart';
import 'package:reddit_clone_provider/features/auth/screens/login_screen.dart';
import 'package:reddit_clone_provider/features/community/screens/create_community_screen.dart';
import 'package:reddit_clone_provider/features/home/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: LoginScreen(),
      ),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: HomeScreen(),
      ),
  '/create-community': (_) => const MaterialPage(
        child: CreateCommunity(),
      ),
});
