import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/user_item.dart';
import 'package:vagoflax/widgets/profile_button.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final users = userProvider.users;
    final isLoading = userProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('Admin Screen'),
        centerTitle: true,
        actions: [const ProfileButton()],
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
            ),
    );
  }
}
