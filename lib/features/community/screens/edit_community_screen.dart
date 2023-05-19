import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return
        // TODO: return ref.watch
        Scaffold(
      appBar: AppBar(
        title: const Text("Edit community"),
        centerTitle: true,
        actions: [
          TextButton(onPressed: () {}, child: const Text("Save")),
        ],
      ),
      body: Column(
        children: <Widget>[
          DottedBorder(
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              // child: Image.network(src)
            ),
          ),
        ],
      ),
    );
  }
}
