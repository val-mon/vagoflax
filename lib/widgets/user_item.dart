import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/models/enum/user_role.dart';

class UserItem extends StatelessWidget {
  final User user;
  const UserItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final hasProfilePicture =
        user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        // profile picture
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: hasProfilePicture
              ? NetworkImage(user.profilePictureUrl!)
              : null,
          child: !hasProfilePicture
              ? const Icon(Icons.person, size: 32, color: Colors.grey)
              : null,
        ),

        // User name
        title: Text(
          user.role == UserRole.student
              ? "${user.firstName ?? 'Unknown'} ${user.lastName ?? 'User'}"
              : user.companyName ?? "Company",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        // Role and location
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge pour le rôle (ex: STUDENT ou EMPLOYER)
              if (user.role != UserRole.unknown)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 6),

              // Localation
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${user.address} - ${user.canton}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          context.push('/profile/${user.id}');
        },
      ),
    );
  }
}
