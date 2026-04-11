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

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: openFiles.length,
        itemBuilder: (context, index) {
          final file = openFiles[index];
          final isActive = file.filePath == currentFile?.filePath;

          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _TabChip(
              file: file,
              isActive: isActive,
              onTap: () => onTabSwitch(file.filePath),
              onClose: () => onTabClose(file.filePath),
            ),
          );
        },
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final TextFile file;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabChip({
    required this.file,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  static const _amberAccent = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isActive
        ? theme.colorScheme.surface
        : Colors.transparent;
    final textColor = isActive
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            bottom: BorderSide(
              color: isActive ? _amberAccent : Colors.transparent,
              width: 2.5,
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
                decoration: const BoxDecoration(
                  color: _amberAccent,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              file.fileName,
              style: TextStyle(color: textColor, fontSize: 13, fontWeight: isActive ? FontWeight.w500 : FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.close, size: 14, color: textColor.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
