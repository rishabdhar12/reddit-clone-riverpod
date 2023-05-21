import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/common/error_widget.dart';
import 'package:reddit_clone_provider/core/common/loader.dart';
import 'package:reddit_clone_provider/core/constants/constants.dart';
import 'package:reddit_clone_provider/core/utils.dart';
import 'package:reddit_clone_provider/features/community/controllers/community_controller.dart';
import 'package:reddit_clone_provider/models/community_model.dart';
import 'package:reddit_clone_provider/theme/palette.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerImage;
  File? profileImage;

  // pick banner image
  void pickBannerImage() async {
    final image = await pickImage();
    if (image != null) {
      setState(() {
        bannerImage = File(image.files.first.path!);
      });
    }
  }

// pick profile image
  void pickProfileImage() async {
    final image = await pickImage();
    if (image != null) {
      setState(() {
        profileImage = File(image.files.first.path!);
      });
    }
  }

  // edit community
  void editCommunity(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        community: community,
        bannerImage: bannerImage,
        profileImage: profileImage,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameStreamFamily(widget.name)).when(
          data: (data) => Scaffold(
            appBar: AppBar(
              title: Text("Edit community - r/${widget.name}"),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () => editCommunity(data),
                  child: const Text("Save"),
                ),
              ],
            ),
            body: isLoading == true
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => pickBannerImage(),
                                child: DottedBorder(
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  color: Pallete.darkModeAppTheme.textTheme
                                      .bodyMedium!.color!,
                                  borderType: BorderType.RRect,
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: bannerImage != null
                                        ? Image.file(bannerImage!)
                                        : (data.banner.isEmpty ||
                                                data.banner ==
                                                    Constants.bannerDefault)
                                            ? const Center(
                                                child: Icon(
                                                    Icons.camera_alt_outlined),
                                              )
                                            : Image.network(data.banner),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: GestureDetector(
                                  onTap: () => pickProfileImage(),
                                  child: profileImage != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(profileImage!),
                                          radius: 40)
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(data.avatar),
                                          radius: 40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          error: (error, stackTrace) => ErrorText(
            errorText: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
