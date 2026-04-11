import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final int currentChapter;
  final int totalChapters;
  final int wordCount;
  final int selectedCharCount;

  const StatusBar({
    super.key,
    this.currentChapter = -1,
    this.totalChapters = 0,
    this.wordCount = 0,
    this.selectedCharCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          // Left: chapter info
          if (totalChapters > 0)
            Text(
              currentChapter >= 0
                  ? '第 ${currentChapter + 1} 章 / 共 $totalChapters 章'
                  : '序章 / 共 $totalChapters 章',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),

          const Spacer(),

          // Center: word count
          Text(
            '$wordCount 字',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
          ),

          if (selectedCharCount > 0 && width >= 600) ...[
            const SizedBox(width: 16),
            Text(
              '已选 $selectedCharCount 字',
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
            ),
          ],

          const Spacer(),

          // Right: progress indicator
          if (totalChapters > 0 && width >= 600)
            Text(
              '进度 ${totalChapters > 0 ? ((currentChapter + 1) * 100 ~/ totalChapters) : 0}%',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
