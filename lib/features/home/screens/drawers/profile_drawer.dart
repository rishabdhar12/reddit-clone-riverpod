import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void signOut(WidgetRef ref) {
    return ref.read(authControllerProvider.notifier).signOut();
  }

// navigate to edit profile screen
  void navigateToEditProfileScreen(BuildContext context,
      {required String uid}) {
    Routemaster.of(context).push('/u/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Drawer(
      width: 240,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(user!.profilePic),
            ),
            const SizedBox(height: 20),
            Text(
              "u/${user.name}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => navigateToEditProfileScreen(context, uid: user.uid),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => signOut(ref),
            ),
            const SizedBox(height: 20),
            Switch.adaptive(
              value: true,
              onChanged: (val) {},
            ),
          ],
        ),
      ),
    );
  }
}
