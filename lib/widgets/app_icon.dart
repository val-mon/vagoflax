import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.size = 120.0});

  final double size;
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/icon/icon.png', width: size, height: size);
  }
}
