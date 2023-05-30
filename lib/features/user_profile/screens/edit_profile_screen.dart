import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/common/error_widget.dart';
import 'package:reddit_clone_provider/core/common/loader.dart';
import 'package:reddit_clone_provider/core/constants/constants.dart';
import 'package:reddit_clone_provider/core/utils.dart';
import 'package:reddit_clone_provider/features/auth/controllers/auth_controller.dart';
import 'package:reddit_clone_provider/features/user_profile/controller/edit_profile_controller.dart';
import 'package:reddit_clone_provider/theme/palette.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Name controller
  TextEditingController nameController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  // dispose controller
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
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

  // save user
  void save() {
    ref.read(userControllerProvider.notifier).editProfile(
        bannerImage: bannerImage,
        profileImage: profileImage,
        context: context,
        name: nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userControllerProvider);
    return ref.watch(getUserProvider(widget.uid)).when(
          data: (data) => Scaffold(
            appBar: AppBar(
              title: Text("Edit profile - u/${data.name}"),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () => save(),
                  child: const Text("Save"),
                ),
              ],
            ),
            body: isLoading
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
                                              NetworkImage(data.profilePic),
                                          radius: 40),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: "Name",
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
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
