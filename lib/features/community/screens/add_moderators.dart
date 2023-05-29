import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/common/error_widget.dart';
import 'package:reddit_clone_provider/core/common/loader.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:reddit_clone_provider/features/community/controllers/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  // member uid list
  Set<String> uid = {};
  int counter = 0;

  // add / remove uid
  void addUid({required String userId}) {
    setState(() {
      uid.add(userId);
    });
  }

  void removeUid({required String userId}) {
    setState(() {
      uid.remove(userId);
    });
  }

  // add moderators
  void saveModerators() {
    ref
        .read(communityControllerProvider.notifier)
        .addModerators(context, communityName: widget.name, uids: uid.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => saveModerators(), icon: const Icon(Icons.save)),
        ],
      ),
      body: ref.watch(getCommunityByNameStreamFamily(widget.name)).when(
          data: (data) => ListView.builder(
              itemCount: data.members.length,
              itemBuilder: (BuildContext context, int index) {
                final member = data.members[index];
                if (!uid.contains(member) && counter == 0) {
                  addUid(userId: member);
                }
                counter++;
                return ref.watch(getUserProvider(member)).when(
                    data: (user) => CheckboxListTile(
                          onChanged: (val) {
                            if (val!) {
                              addUid(userId: member);
                            } else {
                              removeUid(userId: member);
                            }
                          },
                          value: uid.contains(member),
                          title: Text(user.name),
                        ),
                    error: (error, stackTrace) =>
                        ErrorText(errorText: error.toString()),
                    loading: () => const Loader());
              }),
          error: (error, stackTrace) => ErrorText(errorText: error.toString()),
          loading: () => const Loader()),
    );
  }
}
