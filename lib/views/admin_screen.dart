import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:vagoflax/providers/user_provider.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/user_item.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le UserProvider (à adapter selon le nom de ton provider)
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final users = userProvider.users;
    final isLoading = userProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('Admin Screen'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () {
              context.read<ApplicationState>().signOut();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('No users available'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return UserItem(user: user);
              },
              // )
            ),
    );
  }
}
