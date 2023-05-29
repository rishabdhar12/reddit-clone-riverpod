import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_provider/core/constants/constants.dart';
import 'package:reddit_clone_provider/core/constants/firebase_constants.dart';
import 'package:reddit_clone_provider/core/failure.dart';
import 'package:reddit_clone_provider/core/utils.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:reddit_clone_provider/features/auth/repositories/storage_repository_provider.dart';
import 'package:reddit_clone_provider/features/community/repositories/community_repository.dart';
import 'package:reddit_clone_provider/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

// create community controller stream provider
final communityControllerStreamProvider = StreamProvider((ref) {
  final communityControllerStream =
      ref.watch(communityControllerProvider.notifier);
  return communityControllerStream.getUserCommunities();
});

// get communities stream provider family.
final getCommunityByNameStreamFamily =
    StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name: name);
});

// search community stream provider family.
final searchCommunityStreamProviderFamily =
    StreamProvider.family((ref, String query) {
  return ref
      .watch(communityControllerProvider.notifier)
      .searchCommunities(query: query);
});

// community controller provider
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
      communityRepository: communityRepository,
      ref: ref,
      storageRepository: storageRepository);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  CommunityController({
    required CommunityRepository communityRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _communityRepository = communityRepository,
        _storageRepository = storageRepository,
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

// get community by name
  Stream<Community> getCommunityByName({required String name}) {
    return _communityRepository.getCommunityByName(name: name);
  }

  // edit community
  void editCommunity({
    required Community community,
    required File? bannerImage,
    required File? profileImage,
    required BuildContext context,
  }) async {
    state = true;

    // upload profile image
    if (profileImage != null) {
      final res = await _storageRepository.uploadFile(
          path: FirebaseConstants.communitiesProfilePath,
          id: community.name,
          file: profileImage);

      res.fold((e) => showSnackBar(context, e.failureMessage),
          (r) => community = community.copyWith(avatar: r));
    }

    // upload banner image
    if (bannerImage != null) {
      final res = await _storageRepository.uploadFile(
          path: FirebaseConstants.communitiesBannerPath,
          id: community.name,
          file: bannerImage);

      res.fold((e) => showSnackBar(context, e.failureMessage),
          (r) => community = community.copyWith(banner: r));
    }

    // update community firestore
    final res = await _communityRepository.editCommunity(community: community);

    state = false;

    res.fold((e) => showSnackBar(context, e.failureMessage), (r) {
      showSnackBar(context, "Community updated");
      Routemaster.of(context).pop();
    });
  }

  // get streamed list of communities
  Stream<List<Community>> searchCommunities({required String query}) {
    return _communityRepository.searchCommunities(query: query);
  }

  // join community
  void joinOrLeaveCommunity(BuildContext context,
      {required Community community}) async {
    final user = _ref.read(userProvider);
    Either<Failure, void> res;
    if (community.members.contains(user!.uid)) {
      res = await _communityRepository.leaveCommunity(
          communityName: community.name, uid: user.uid);
    } else {
      res = await _communityRepository.joinCommunity(
          communityName: community.name, uid: user.uid);
    }

    res.fold((l) => showSnackBar(context, l.failureMessage), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, "Community left");
      } else {
        showSnackBar(context, "Community joined");
      }
    });
  }

// add mods
  void addModerators(BuildContext context,
      {required String communityName, required List<String> uids}) async {
    final res = await _communityRepository.addModerators(
        communityName: communityName, uids: uids);

    res.fold((l) => showSnackBar(context, l.failureMessage),
        (r) => Routemaster.of(context).pop());
  }
}
