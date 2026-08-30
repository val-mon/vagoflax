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
                              user.profilePictureUrl!,
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
                  const _SectionTitle(title: 'Ratings'),
                  const SizedBox(height: 14),
                  UserRatingBadge(
                    rating: user.averageRating,
                    count: user.reviewCount,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Personal Information'),
                  const SizedBox(height: 14),
                  // firstname et lastname si étudiant, sinon companyname
                  if (user.role == UserRole.student) ...[
                    _InfoRow(icon: Icons.person, title: 'First name', value: user.firstName ?? ''),
                    _InfoRow(icon: Icons.person, title: 'Last name', value: user.lastName ?? ''),
                  ] else if (user.hasProfilePicture &&
                      user.role == UserRole.employer) ...[
                    _InfoRow(icon: Icons.business, title: 'Company Name', value: user.companyName ?? ''),
                  ],

                  _InfoRow(icon: Icons.email, title: 'Email', value: user.email),
                  const SizedBox(height: 20),
                  _InfoRow(icon: Icons.location_city, title: 'City', value: user.city),
                  _InfoRow(icon: Icons.location_on, title: 'Canton', value: user.canton),
                  _InfoRow(icon: Icons.description, title: 'Description', value: user.description),
                  const SizedBox(height: 12),

                  const _SectionTitle(title: 'Skills'),
                  const SizedBox(height: 14),

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
                  const _SectionTitle(title: 'Languages'),
                  const SizedBox(height: 14),

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
                  ] else if (userProvider.currentUser!.role !=
                      UserRole.admin) ...[
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
}
/// Displays a section title with a divider underneath.
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Divider(thickness: 1, height: 1),
      ],
    );
  }
}

/// Displays job information with an icon and a value.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Displays a diploma or language as a small chip.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),

          const SizedBox(width: 6),

          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

