class Job {
  final String id;
  final String title;
  final String description;
  final String company;
  final String location;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
  });

  /// Builds a Job object from a Firestore document.
  factory Job.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Job(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
    );
  }
}
