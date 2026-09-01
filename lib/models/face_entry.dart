/// A single entry of the public face index: just enough to find back the email
/// of the person in front of the camera, without exposing their profile.
class FaceEntry {
  final String email;
  final List<double> signature;

  const FaceEntry({required this.email, required this.signature});

  factory FaceEntry.fromFirestore(Map<String, dynamic> data) {
    return FaceEntry(
      email: data['email'] ?? '',
      signature: ((data['signature'] as List<dynamic>?) ?? [])
          .map((value) => (value as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'signature': signature,
  };
}
