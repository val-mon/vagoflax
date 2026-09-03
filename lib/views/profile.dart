import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/models/enum/status.dart';
import 'package:vagoflax/models/enum/user_role.dart';
import 'package:vagoflax/models/job_application.dart';
import 'package:vagoflax/models/user.dart';
import 'package:vagoflax/providers/application.dart';
import 'package:vagoflax/providers/job.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:vagoflax/widgets/leave_review_sheet.dart';
import 'package:vagoflax/widgets/logout_button.dart';
import 'package:vagoflax/providers/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:vagoflax/widgets/user_rating_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showAllReviews = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _ratingsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToRatings() {
    final context = _ratingsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showAddReviewDialog(
    BuildContext context,
    User targetUser,
    String currentUserId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeaveReviewSheet(
        targetUserId: targetUser.id,
        currentUserId: currentUserId,
      ),
    );
  }

  bool canUserReview(User targetUser, User currentUser) {
    final applicationProvider = context.read<ApplicationProvider>();
    final jobProvider = context.read<JobProvider>();

    List<JobApplication> jobApplications;

    if (currentUser.role == UserRole.student) {
      // if currentuser is student, check if he has any completed applications with the target user
      final employerJobs = jobProvider.jobs
          .where((job) => job.userUuid == targetUser.id)
          .map((job) => job.id)
          .toList();

      jobApplications = applicationProvider.applications
          .where((app) => employerJobs.contains(app.jobId))
          .toList();

      jobApplications.retainWhere(
        (app) =>
            app.studentUuid == currentUser.id &&
            (app.status == Status.accepted || app.status == Status.rejected),
      );
    } else if (currentUser.role == UserRole.employer) {
      // if current user is employer, check my jobs, for every job check if there is at least one application with the target user that is completed
      final employerJobs = jobProvider.jobs
          .where((job) => job.userUuid == currentUser.id)
          .map((job) => job.id)
          .toList();
      jobApplications = applicationProvider.applications
          .where((app) => employerJobs.contains(app.jobId))
          .toList();

      jobApplications.retainWhere(
        (app) =>
            app.studentUuid == targetUser.id &&
            (app.status == Status.accepted || app.status == Status.rejected),
      );
    } else {
      // if the current user is neither student nor employer, they cannot leave a review
      return false;
    }

    if (jobApplications.isEmpty) {
      return false;
    }

    // check if the current user has already reviewed the target user
    if (targetUser.hasUserBeenReviewedBy(currentUser.id)) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    User user;

    if (widget.userId != null) {
      final foundUser = userProvider.getUserFromId(widget.userId!);
      if (foundUser == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: const Center(child: Text('User not found')),
        );
      } else {
        user = foundUser;
      }
    } else {
      user = currentUser;
    }

    final isOwnProfile = user.id == currentUser.id;
    final hasAlreadyReviewed = user.hasUserBeenReviewedBy(currentUser.id);
    final canReview = canUserReview(user, currentUser);

    final history = user.history;

    if (history.isNotEmpty) {
      history.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (isOwnProfile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Profile',
                  onPressed: () async {
                    await context.push('/profile/edit');
                    if (context.mounted) {
                      await context.read<ApplicationState>().reloadUserData();
                    }
                  },
                ),
                const LogoutButton(),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: user.hasProfilePicture
                              ? NetworkImage(user.profilePictureUrl!)
                              : null,
                          child: !user.hasProfilePicture
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _scrollToRatings,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: UserRatingBadge(
                                rating: user.averageRating,
                                count: user.reviewCount,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Personal Information'),
                  const SizedBox(height: 14),
                  if (user.role == UserRole.student) ...[
                    _InfoRow(
                      icon: Icons.person,
                      title: 'First name',
                      value: user.firstName ?? '',
                    ),
                    _InfoRow(
                      icon: Icons.person,
                      title: 'Last name',
                      value: user.lastName ?? '',
                    ),
                  ] else if (user.hasProfilePicture &&
                      user.role == UserRole.employer) ...[
                    _InfoRow(
                      icon: Icons.business,
                      title: 'Company Name',
                      value: user.companyName ?? '',
                    ),
                  ],

                  _InfoRow(
                    icon: Icons.email,
                    title: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(
                    icon: Icons.location_city,
                    title: 'Address',
                    value: user.address,
                  ),
                  _InfoRow(
                    icon: Icons.location_on,
                    title: 'Canton',
                    value: user.canton,
                  ),
                  _InfoRow(
                    icon: Icons.description,
                    title: 'Description',
                    value: user.description,
                  ),
                  const SizedBox(height: 12),

                  if (user.role == UserRole.student) ...[
                    const _SectionTitle(title: 'Skills'),
                    const SizedBox(height: 14),

                    user.skills.isEmpty
                        ? const Text('-')
                        : Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: user.skills
                                .map(
                                  (s) => _InfoChip(icon: Icons.star, label: s),
                                )
                                .toList(),
                          ),
                    const SizedBox(height: 16),
                    const _SectionTitle(title: 'History'),
                    const SizedBox(height: 14),

                    history.isEmpty
                        ? const Text('-')
                        : Column(
                            children: history
                                .map(
                                  (h) => _InfoRow(
                                    icon: Icons.work,
                                    title: h.jobTitle,
                                    value:
                                        '${h.company} (${h.startedAt.year} to ${h.endedAt.year})',
                                  ),
                                )
                                .toList(),
                          ),
                  ],
                  const SizedBox(height: 24),
                  _SectionTitle(key: _ratingsKey, title: 'Ratings'),
                  const SizedBox(height: 14),
                  // Ratings Badge + Add Review Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UserRatingBadge(
                        rating: user.averageRating,
                        count: user.reviewCount,
                      ),
                      if (!isOwnProfile)
                        OutlinedButton.icon(
                          onPressed: hasAlreadyReviewed || !canReview
                              ? null
                              : () => _showAddReviewDialog(
                                  context,
                                  user,
                                  currentUser.id,
                                ),
                          icon: Icon(
                            hasAlreadyReviewed
                                ? Icons.check
                                : Icons.rate_review_outlined,
                            size: 18,
                          ),
                          label: Text(
                            hasAlreadyReviewed
                                ? 'Reviewed'
                                : canReview
                                ? 'Leave a Review'
                                : 'Cannot Review',
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (user.reviewCount > 0) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAllReviews = !showAllReviews;
                          });
                        },
                        child: Text(
                          showAllReviews
                              ? 'Hide Reviews'
                              : 'Show All Reviews (${user.reviewCount})',
                        ),
                      ),
                    ),
                    if (showAllReviews)
                      Column(
                        children: [
                          ...user.reviews.expand((review) {
                            final reviewer = userProvider.getUserFromId(
                              review.reviewerId,
                            );
                            final userName = reviewer == null
                                ? "Unknown User"
                                : reviewer.role == UserRole.employer
                                ? reviewer.companyName ?? 'Unknown Company'
                                : '${reviewer.firstName ?? 'Unknown'} ${reviewer.lastName ?? 'User'}';
                            final userLocation = reviewer == null
                                ? ""
                                : ' • ${reviewer.canton}';
                            return [
                              ListTile(
                                title: Text(userName + userLocation),
                                subtitle: Text(review.comment),
                                trailing: UserRatingBadge(
                                  rating: review.rating,
                                  count: -1,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ].toList();
                          }),
                        ],
                      ),
                  ],
                  // leave a bit of room to have the last review fully visible when scrolling
                  const SizedBox(height: 200),
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

  const _SectionTitle({super.key, required this.title});

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
