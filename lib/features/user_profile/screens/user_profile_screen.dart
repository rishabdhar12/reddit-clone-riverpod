import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/common/error_widget.dart';
import 'package:reddit_clone_provider/core/common/loader.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  // navigate to edit profile
  void navigateToEditProfile(BuildContext context) {
    Routemaster.of(context).push("/edit-profile/$uid");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(getUserProvider(uid)).when(
          data: (user) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.network(
                            user.banner,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                user.profilePic,
                              ),
                              radius: 36,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "u/${user.name}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => navigateToEditProfile(context),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 26),
                                ),
                                child: const Text(
                                  "Edit Profile",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: const Text("Displaying name")),
          error: (error, stackTrace) => ErrorText(
                errorText: error.toString(),
              ),
          loading: () => const Loader()),
    );
  }
}
