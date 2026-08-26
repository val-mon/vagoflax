import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vagoflax/providers/app_state.dart';

class LogoutButton extends StatelessWidget {
   const LogoutButton({super.key});

   @override
   Widget build(BuildContext context) {
     return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Log out',
      onPressed: () {
        context.read<ApplicationState>().signOut();
      },
    );
   }
 }