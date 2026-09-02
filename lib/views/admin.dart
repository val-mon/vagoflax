import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/widgets/about_icon.dart';
import 'package:vagoflax/widgets/profile_button.dart';
import 'package:vagoflax/widgets/search_filter.dart';
import 'package:vagoflax/widgets/user_item.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _searchQuery = '';

  String _getUserName(User b) =>
      (b.role == UserRole.student
          ? "${b.firstName} ${b.lastName}"
          : b.companyName) ??
      b.email;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isLoading = userProvider.isLoading;

    final sortedUsers = List<User>.from(userProvider.users)
      ..sort((a, b) => _getUserName(a).compareTo(_getUserName(b)));

    final filteredUsers = sortedUsers.where((user) {
      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = _getUserName(user).toLowerCase();
      final email = user.email.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AboutIcon(),
        title: const Text('Admin Screen'),
        centerTitle: true,
        actions: const [ProfileButton()],
      ),
      body: Column(
        children: [
          SearchFilter(
            onSearch: (value) => setState(() => _searchQuery = value),
            onFilterTap: () {},
            filters: false,
            text: "Search users",
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                ? const Center(child: Text('No users available'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return UserItem(user: filteredUsers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
