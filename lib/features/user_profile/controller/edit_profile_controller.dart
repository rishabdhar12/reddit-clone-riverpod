import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/utils.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:reddit_clone_provider/features/auth/repositories/storage_repository_provider.dart';
import 'package:reddit_clone_provider/features/user_profile/repository/edit_profile_repository.dart';
import 'package:reddit_clone_provider/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

// edit profile controller provider
final userControllerProvider =
    StateNotifierProvider<EditProfileController, bool>((ref) {
  final userRepository = ref.watch(editProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return EditProfileController(
      editProfileRepository: userRepository,
      ref: ref,
      storageRepository: storageRepository);
});

class EditProfileController extends StateNotifier<bool> {
  final EditProfileRepository _editProfileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  EditProfileController({
    required EditProfileRepository editProfileRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _editProfileRepository = editProfileRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

// edit profile
  void editProfile({
    required File? bannerImage,
    required File? profileImage,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    // upload profile image
    if (profileImage != null) {
      final res = await _storageRepository.uploadFile(
          path: 'users/profile', id: user.uid, file: profileImage);

      res.fold((e) => showSnackBar(context, e.failureMessage),
          (r) => user = user.copyWith(profilePic: r));
    }

    // upload banner image
    if (bannerImage != null) {
      final res = await _storageRepository.uploadFile(
          path: 'users/banner', id: user.uid, file: bannerImage);

      res.fold((e) => showSnackBar(context, e.failureMessage),
          (r) => user = user.copyWith(banner: r));
    }

    user = user.copyWith(name: name);

    // update user firestore
    final res = await _editProfileRepository.editProfile(userModel: user);

    state = false;

    res.fold((e) => showSnackBar(context, e.failureMessage), (r) {
      showSnackBar(context, "User updated");
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }
}
