import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job_model.dart';
import '../models/enum/diplomas_model.dart';
import '../models/enum/role_model.dart';
import '../models/enum/perks_model.dart';
import '../models/enum/languages_model.dart';
import '../models/enum/industry_model.dart';

class JobForm extends StatefulWidget {
  const JobForm({super.key}); 

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Job Title')),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Job Description'),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              jobProvider.addJob(
                Job(
                  title: 'New Job Title',
                  description: 'New Job Description',
                  role: Role.intern,
                  diplomas: [Diplomas.bachelor],
                  industry: Industry.informationTechnology,
                  perks: [Perks.mealVouchers],
                  languages: [Languages.english],
                  holidays: 20,
                  maternityLeave: 14,
                  paternityLeave: 2,
                  workloadPercent: 100,
                  salary: 60000,
                  predictedSalary: 62000,
                  contractTime: 12,
                ),
                'user-uuid-placeholder', // TODO: Replace with the UUID of the connected user
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
