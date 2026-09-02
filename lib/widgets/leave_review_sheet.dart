import 'package:flutter/material.dart';
import 'package:vagoflax/providers/user.dart';
import 'package:provider/provider.dart';

class LeaveReviewSheet extends StatefulWidget {
  final String targetUserId;
  final String currentUserId;

  const LeaveReviewSheet({
    super.key,
    required this.targetUserId,
    required this.currentUserId,
  });

  @override
  State<LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends State<LeaveReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _commentError;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Leave a Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber.shade700,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _rating = starIndex),
                );
              }),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience with this user...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _commentError,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final comment = _commentController.text.trim();

                      setState(() {
                        if (comment.isEmpty) {
                          _commentError = 'Please write a comment';
                        } else if (comment.length > 250) {
                          _commentError =
                              'Comment is too long (max 250 characters)';
                        } else {
                          _commentError = null;
                        }
                      });

                      if (_commentError != null) return;

                      setState(() => _isSubmitting = true);

                      try {
                        await context.read<UserProvider>().addReview(
                          targetUserId: widget.targetUserId,
                          reviewerId: widget.currentUserId,
                          rating: _rating,
                          comment: comment,
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review submitted!')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        setState(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Review', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
