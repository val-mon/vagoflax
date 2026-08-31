import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:provider/provider.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final ppUrl = userProvider.currentUser?.profilePictureUrl;
    final hasImage = ppUrl != null && ppUrl.trim().isNotEmpty;

    return IconButton(
      tooltip: 'Profile',
      onPressed: () => context.push('/profile'),
      icon: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: hasImage ? NetworkImage(ppUrl) : null,
        child: hasImage
            ? null
            : const Icon(Icons.person, size: 18, color: Colors.grey),
      ),
    );
  }
}
