import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../bloc/library_bloc.dart' show LibraryFilter;

/// Deep dark navigation sidebar — Koodo Reader style
class NavSidebar extends StatelessWidget {
  final LibraryFilter selectedFilter;
  final ValueChanged<LibraryFilter> onFilterChanged;
  final VoidCallback onImportFile;
  final int allCount;
  final int favoriteCount;
  final int recentCount;
  final int trashCount;

  const NavSidebar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onImportFile,
    this.allCount = 0,
    this.favoriteCount = 0,
    this.recentCount = 0,
    this.trashCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.lightSidebar,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.auto_stories, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Text Edit Read',
                  style: TextStyle(
                    color: AppColors.lightSidebarText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Navigation items
          _NavSection(
            items: [
              _NavItem(icon: Icons.home, label: '全部文件', count: allCount, filter: LibraryFilter.all),
              _NavItem(icon: Icons.favorite_border, label: '我的喜爱', count: favoriteCount, filter: LibraryFilter.favorites),
              _NavItem(icon: Icons.access_time, label: '最近打开', count: recentCount, filter: LibraryFilter.recent),
              _NavItem(icon: Icons.delete_outline, label: '回收站', count: trashCount, filter: LibraryFilter.trash),
            ],
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),

          const Spacer(),

          // Bottom: import button
          Padding(
            padding: const EdgeInsets.all(16),
            child: _ImportButton(onTap: onImportFile),
          ),
        ],
      ),
    );
  }
}

class _NavSection extends StatelessWidget {
  final List<_NavItem> items;
  final LibraryFilter selectedFilter;
  final ValueChanged<LibraryFilter> onFilterChanged;

  const _NavSection({
    required this.items,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final isActive = item.filter == selectedFilter;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: InkWell(
            onTap: () => onFilterChanged(item.filter),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: isActive ? AppColors.primary : AppColors.lightSidebarText.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? AppColors.lightSidebarText : AppColors.lightSidebarText.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (item.count > 0)
                    Text(
                      '${item.count}',
                      style: TextStyle(
                        color: AppColors.lightSidebarText.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int count;
  final LibraryFilter filter;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.filter,
  });
}

class _ImportButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ImportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              '导入文件',
              style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
