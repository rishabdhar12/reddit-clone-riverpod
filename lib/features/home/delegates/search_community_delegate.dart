import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/common/error_widget.dart';
import 'package:reddit_clone_provider/core/common/loader.dart';
import 'package:reddit_clone_provider/features/community/controllers/community_controller.dart';
import 'package:reddit_clone_provider/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;

  SearchCommunityDelegate({required this.ref});

// navigate to community page
  void navigateToCommunityScreen(BuildContext context, Community community) {
    Routemaster.of(context).push("/r/${community.name}");
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityStreamProviderFamily(query)).when(
        data: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final community = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(community.avatar),
                ),
                title: Text("r/${community.name}"),
                onTap: () => navigateToCommunityScreen(context, community),
              );
            }),
        error: (error, stackTrace) => ErrorText(
              errorText: error.toString(),
            ),
        loading: () => const Loader());
  }
}
