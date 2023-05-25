import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/common/error_widget.dart';
import 'package:reddit_clone_provider/core/common/loader.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:reddit_clone_provider/features/community/controllers/community_controller.dart';
import 'package:reddit_clone_provider/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  void navigateToModToolsScreen(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  // join/leave community
  void joinOrLeaveCommunity(WidgetRef ref, BuildContext context,
      {required Community community}) {
    ref
        .read(communityControllerProvider.notifier)
        .joinOrLeaveCommunity(context, community: community);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      body: ref.watch(getCommunityByNameStreamFamily(name)).when(
          data: (community) => NestedScrollView(
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
                            community.banner,
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
                                community.avatar,
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
                                "r/${community.name}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              community.mods.contains(user!.uid)
                                  ? OutlinedButton(
                                      onPressed: () {
                                        navigateToModToolsScreen(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 26),
                                      ),
                                      child: const Text("Mod Tools"),
                                    )
                                  : OutlinedButton(
                                      onPressed: () => joinOrLeaveCommunity(
                                          ref, context,
                                          community: community),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 26),
                                      ),
                                      child: Text(
                                        community.members.contains(user.uid)
                                            ? "Joined"
                                            : "Join",
                                      ),
                                    ),
                            ],
                          ),
                          Text("${community.members.length} members"),
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
