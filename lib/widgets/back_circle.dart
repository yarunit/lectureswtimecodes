import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BackCircle extends StatelessWidget {
  const BackCircle({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
