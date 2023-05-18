import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/constants/constants.dart';
import 'package:reddit_clone_provider/core/utils.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:reddit_clone_provider/features/community/repositories/community_repositories.dart';
import 'package:reddit_clone_provider/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

// create community controller stream provider
final communityControllerStreamProvider = StreamProvider((ref) {
  final communityControllerStream =
      ref.watch(communityControllerProvider.notifier);
  return communityControllerStream.getUserCommunities();
});

// community controller provider
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  return CommunityController(
      communityRepository: communityRepository, ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;

  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        super(false);

  // create community controller
  void createCommunity(String name, BuildContext context) async {
    // isLoading
    state = true;

    // get user id
    final uid = _ref.read(userProvider)?.uid ?? "";

    // community model
    Community communityModel = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final community =
        await _communityRepository.createCommunity(communityModel);

    // isLoading = false
    state = false;

    // return result
    community.fold((l) => showSnackBar(context, l.failureMessage), (r) {
      showSnackBar(context, "Community created successfully");
      Routemaster.of(context).pop();
    });
  }

  // get users communities stream controller
  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }
}
