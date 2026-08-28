class Review {
  final DateTime createdAt;
  final String reviewerId;
  final String comment;
  final double rating;

  Review({
    required this.createdAt,
    required this.reviewerId,
    required this.comment,
    required this.rating,
  }) : assert(rating >= 0.0 && rating <= 5.0, 'Rating must be between 0 and 5');
}
