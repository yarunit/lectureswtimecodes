import 'package:flutter/material.dart';

import '../format.dart';
import '../models/lecture.dart';
import '../theme/app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
    required this.lectures,
    required this.onOpen,
    required this.onAdd,
  });

  final List<Lecture> lectures;
  final ValueChanged<Lecture> onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final total = lectures.fold<Duration>(Duration.zero, (sum, lecture) => sum + lecture.length);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LIBRARY', style: AppTheme.label(context)),
                      const SizedBox(height: 6),
                      Text('Lectures', style: AppTheme.serif(context, 48)),
                    ],
                  ),
                ),
                _AddButton(onPressed: onAdd),
              ],
            ),
            const SizedBox(height: 22),
            for (var i = 0; i < lectures.length; i++) ...[
              _LectureCard(
                index: i + 1,
                lecture: lectures[i],
                onTap: () => onOpen(lectures[i]),
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 8),
            Text(
              '${lectures.length} lectures · ${formatLength(total)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  const _LectureCard({
    required this.index,
    required this.lecture,
    required this.onTap,
  });

  final int index;
  final Lecture lecture;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    final number = index.toString().padLeft(2, '0');

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      number,
                      style: TextStyle(color: ink.withValues(alpha: 0.38), fontSize: 15, height: 1.4),
                    ),
                  ),
                  Expanded(
                    child: Text(lecture.title, style: AppTheme.serif(context, 26, height: 1.15)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const SizedBox(width: 36),
                  Text(
                    '${formatDate(lecture.date)} · ${formatLength(lecture.length)}',
                    style: TextStyle(color: ink.withValues(alpha: 0.45), fontSize: 14),
                  ),
                  const Spacer(),
                  if (lecture.topics.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${lecture.topics.length} topics',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
