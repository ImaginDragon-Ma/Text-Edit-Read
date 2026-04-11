import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../bloc/library_bloc.dart';

/// File card — displays file info with icon, name, size, date
class FileCard extends StatelessWidget {
  final LibraryFile file;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDeleteTap;

  const FileCard({
    super.key,
    required this.file,
    required this.onTap,
    this.onFavoriteTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon area
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(
                    _getFileIcon(file.fileExtension),
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            // Info area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${file.displaySize}  ·  ${file.displayDate}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    // Actions row
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            file.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: file.isFavorite ? AppColors.primary : theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: onFavoriteTap,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          padding: EdgeInsets.zero,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          onPressed: onDeleteTap,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String ext) {
    switch (ext) {
      case 'txt': return Icons.description;
      case 'md': return Icons.article;
      default: return Icons.insert_drive_file;
    }
  }
}
