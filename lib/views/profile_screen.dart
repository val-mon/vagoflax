import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/widgets/logout_button.dart';
import 'package:vagoflax/providers/app_state.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ApplicationState>();

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
                      backgroundImage: state.profilePicture.isNotEmpty
                          ? NetworkImage(state.profilePicture)
                          : null,
                      child: state.profilePicture.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _line('First name', state.firstName),
                  _line('Last name', state.lastName),
                  _line('Email', state.email),
                  const SizedBox(height: 20),
                  _line('City', state.city),
                  _line('Canton', state.canton),
                  _line('Description', state.description),
                  const SizedBox(height: 12),

                  Text('Skills', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  state.skills.isEmpty
                      ? const Text('-')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: state.skills
                              .map((s) => Chip(label: Text(s)))
                              .toList(),
                        ),
                  const SizedBox(height: 16),
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  state.history.isEmpty
                      ? const Text('-')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: state.history
                              .map((h) => Text('• $h'))
                              .toList(),
                        ),
                  const SizedBox(height: 24),
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
