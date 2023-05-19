import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  void navigateToEditCommunityScreen(BuildContext context) {
    Routemaster.of(context).push("/edit-community/$name");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mod Tools - r/$name"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text("Add Moderator"),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Community"),
            onTap: () {
              navigateToEditCommunityScreen(context);
            },
          ),
        ],
      ),
    );
  }
}
