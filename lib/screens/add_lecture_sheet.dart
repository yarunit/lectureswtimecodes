import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AddChoice { record, openFile }

Future<AddChoice?> showAddLectureSheet(BuildContext context) {
  return showModalBottomSheet<AddChoice>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final ink = Theme.of(context).colorScheme.onSurface;
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('NEW LECTURE', style: AppTheme.label(context)),
            const SizedBox(height: 8),
            Text('Add one', style: AppTheme.serif(context, 36)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(AddChoice.record),
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
                onPressed: () => Navigator.of(context).pop(AddChoice.openFile),
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
      );
    },
  );
}
