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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (totalChapters > 0)
            _buildChip(
              '${currentChapter >= 0 ? "章节 ${currentChapter + 1}" : "序章"} / $totalChapters',
              theme,
            ),
          if (!isMobile) const SizedBox(width: 16),
          _buildChip('$wordCount 字', theme),
          if (selectedCharCount > 0) ...[
            if (!isMobile) const SizedBox(width: 16),
            _buildChip('已选 $selectedCharCount 字', theme),
          ],
          const Spacer(),
          if (!isMobile)
            Text(
              'Ctrl+滚轮缩放 | Pinch-to-zoom',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
    );
  }
}
