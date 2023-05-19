import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/common/error_widget.dart';
import 'package:reddit_clone_provider/core/common/loader.dart';
import 'package:reddit_clone_provider/features/community/controllers/community_controller.dart';
import 'package:reddit_clone_provider/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  // navigate to create community page
  void navigateToCreateCommunityScreen(BuildContext context) {
    Routemaster.of(context).push("/create-community");
  }

  // navigate to community page
  void navigateToCommunityScreen(BuildContext context, Community community) {
    Routemaster.of(context).push("/r/${community.name}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 240,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.add,
              ),
              title: const Text("Create community"),
              onTap: () => navigateToCreateCommunityScreen(context),
            ),
            const SizedBox(
              height: 20,
            ),

            // get communities
            ref.watch(communityControllerStreamProvider).when(
                data: (data) => Expanded(
                      child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final community = data[index];
                            return ListTile(
                              title: Text("r/${community.name}"),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              onTap: () {
                                navigateToCommunityScreen(context, community);
                              },
                            );
                          }),
                    ),
                error: (error, stackTrace) {
                  return ErrorText(errorText: error.toString());
                },
                loading: () => const Loader())
          ],
        ),
      ),
    );
  }
}
