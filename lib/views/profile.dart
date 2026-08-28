import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/enum/user_role_model.dart';
import 'package:vagoflax/models/user_model.dart';
import 'package:vagoflax/providers/user_provider.dart';
import 'package:vagoflax/widgets/leave_review_sheet.dart';
import 'package:vagoflax/widgets/logout_button.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/widgets/user_rating_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    User user;

    // if userId is provided, we are viewing another user's profile, otherwise we are viewing our own profile
    if (userId != null) {
      final foundUser = userProvider.getUserFromId(userId!);
      if (foundUser == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: const Center(child: Text('User not found')),
        );
      } else {
        user = foundUser;
      }
    } else {
      user = userProvider.currentUser!;
    }

    final userAlreadyReviewed =
        user.id != userProvider.currentUser!.id &&
        user.hasUserBeenReviewedBy(userProvider.currentUser!.id);

    print("profilePictureUrl: ${user.profilePictureUrl}, hasProfilePicture: ${user.hasProfilePicture}");

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: user.hasProfilePicture
                          ? NetworkImage(
                              userProvider.currentUser!.profilePictureUrl!,
                            )
                          : null,
                      child: !user.hasProfilePicture
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  UserRatingBadge(rating: user.averageRating, count: user.reviewCount,),
                  const SizedBox(height: 24),

                  // firstname et lastname si étudiant, sinon companyname
                  if (user.role == UserRole.student) ...[
                    _line('First name', user.firstName ?? ''),
                    _line('Last name', user.lastName ?? ''),
                  ] else if (user.hasProfilePicture &&
                      user.role == UserRole.employer) ...[
                    _line('Company Name', user.companyName ?? ''),
                  ],

                  _line('Email', user.email),
                  const SizedBox(height: 20),
                  _line('City', user.city),
                  _line('Canton', user.canton),
                  _line('Description', user.description),
                  const SizedBox(height: 12),

                  Text('Skills', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  user.skills.isEmpty
                      ? const Text('-')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: user.skills
                              .map((s) => Chip(label: Text(s)))
                              .toList(),
                        ),
                  const SizedBox(height: 16),
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  user.history.isEmpty
                      ? const Text('-')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: user.history
                              .map((h) => Text('• $h'))
                              .toList(),
                        ),
                  const SizedBox(height: 24),
                  if (user.id == userProvider.currentUser!.id) ...[
                    // Only show edit and logout buttons if viewing own profile

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await context.push('/profile/edit');
                            if (context.mounted) {
                              await context
                                  .read<ApplicationState>()
                                  .reloadUserData();
                            }
                          },
                          child: const Text('Edit'),
                        ),
                        const LogoutButton(),
                      ],
                    ),
                  ] else ...[
                    // Show message if viewing another user's profile
                    Center(
                      child: userAlreadyReviewed
                          ? const Text('You have already reviewed this user')
                          : ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (ctx) => LeaveReviewSheet(
                                    targetUserId: user.id,
                                    currentUserId: userProvider.currentUser!.id,
                                  ),
                                );
                              },
                              child: const Text('Leave a review'),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
