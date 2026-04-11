import 'package:flutter/material.dart';
import '../../../core/models/text_file.dart';

class FileTabBar extends StatelessWidget {
  final List<TextFile> openFiles;
  final TextFile? currentFile;
  final ValueChanged<String> onTabSwitch;
  final ValueChanged<String> onTabClose;

  const FileTabBar({
    super.key,
    required this.openFiles,
    this.currentFile,
    required this.onTabSwitch,
    required this.onTabClose,
  });

  @override
  Widget build(BuildContext context) {
    if (openFiles.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: isMobile ? 40 : 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: openFiles.length,
        itemBuilder: (context, index) {
          final file = openFiles[index];
          final isActive = file.filePath == currentFile?.filePath;

          return _TabItem(
            file: file,
            isActive: isActive,
            onTap: () => onTabSwitch(file.filePath),
            onClose: () => onTabClose(file.filePath),
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final TextFile file;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabItem({
    required this.file,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.isModified)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              file.fileName,
              style: TextStyle(color: labelColor, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(4),
              child: Icon(Icons.close, size: 14, color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
