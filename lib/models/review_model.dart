class Review {
  final DateTime createdAt;
  final String from;
  final String message;
  final double rating;

  Review({
    required this.createdAt,
    required this.from,
    this.message = '',
    required this.rating,
  }) : assert(rating >= 0.0 && rating <= 5.0, 'Rating must be between 0 and 5');
}
