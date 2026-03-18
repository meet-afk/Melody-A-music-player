import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AudioBorder extends StatelessWidget {
  final Widget child;
  const AudioBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Pallete.borderColor, 
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Pallete.backgroundColor, 
      ),
      child: child,
    );
  }
}