import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.graphic_eq, color: Colors.white),
              ),
              const Spacer(),
              Text('YOUR STUDY COMPANION', style: AppTheme.label(context)),
              const SizedBox(height: 10),
              Text('Lectures', style: AppTheme.serif(context, 64)),
              const SizedBox(height: 14),
              Text(
                'Turn any lecture into clear topics\nyou can return to in a tap.',
                style: TextStyle(fontSize: 18, height: 1.35, color: ink.withValues(alpha: 0.62)),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  icon: const Icon(Icons.circle, size: 8),
                  label: const Text('Record', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: onAdd,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ink,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: ink.withValues(alpha: 0.06)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Open file', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
