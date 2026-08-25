import '../models/job_model.dart';
import 'job_repository.dart';

class FakeJobRepository implements JobRepository {
  @override
  Stream<List<Job>> getJobs() {
    final fakeJobs = [
      Job(
        id: '1',
        title: 'Dev',
        description: 'Dev Flutter',
        company: 'Vagoflax',
        location: 'Lausanne'
      ),
      Job(
        id: '2',
        title: 'Data Analyst',
        description: 'Data Analyst',
        company: 'Vagoflax',
        location: 'Sion'
      ),
      Job(
        id: '3',
        title: 'Project Manager',
        description: 'Project Manager',
        company: 'Vagoflax',
        location: 'Sierre'
      ),
    ];

    return Stream.value(fakeJobs);
  }
}