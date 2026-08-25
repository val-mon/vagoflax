import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutIcon extends StatelessWidget {
  const AboutIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () {
        context.push('/about');
      },
    );
  }
}