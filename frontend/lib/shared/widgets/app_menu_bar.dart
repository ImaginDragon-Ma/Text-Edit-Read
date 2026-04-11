import 'package:flutter/material.dart';
import 'search_bar.dart';

class AppMenuBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenFile;
  final VoidCallback onSaveFile;
  final VoidCallback onSaveFileAs;
  final VoidCallback onToggleTheme;
  final VoidCallback? onCleanText;
  final VoidCallback? onFindReplace;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onToggleSettings;
  final bool isDarkTheme;
  final bool sidebarCollapsed;
  final bool settingsPanelOpen;

  const AppMenuBar({
    super.key,
    required this.onOpenFile,
    required this.onSaveFile,
    required this.onSaveFileAs,
    required this.onToggleTheme,
    this.onCleanText,
    this.onFindReplace,
    this.onToggleSidebar,
    this.onToggleSettings,
    required this.isDarkTheme,
    this.sidebarCollapsed = false,
    this.settingsPanelOpen = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return AppBar(
        toolbarHeight: 48,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.auto_stories, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text('Text Edit Read',
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, size: 20), onPressed: onFindReplace),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'open': onOpenFile();
                case 'save': onSaveFile();
                case 'save_as': onSaveFileAs();
                case 'theme': onToggleTheme();
                case 'clean': onCleanText?.call();
                case 'find': onFindReplace?.call();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'open', child: Text('打开文件')),
              const PopupMenuItem(value: 'save', child: Text('保存')),
              const PopupMenuItem(value: 'save_as', child: Text('另存为')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'clean', child: Text('整理文本')),
              const PopupMenuItem(value: 'find', child: Text('查找替换')),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'theme', child: Text(isDarkTheme ? '亮色主题' : '暗色主题')),
            ],
          ),
        ],
      );
    }

    // Tablet/Desktop top bar: Logo | Search | Tools
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: onToggleSidebar,
            child: Row(
              children: [
                Icon(Icons.auto_stories, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text('Text Edit Read',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Search bar (desktop only)
          if (width >= 1200)
            Expanded(child: AppSearchBar(onSearch: (_) {}, onClear: () {}))
          else
            IconButton(icon: const Icon(Icons.search, size: 20), tooltip: '搜索', onPressed: onFindReplace),

          const Spacer(),

          // Tool buttons
          if (width >= 600) ...[
            _ToolButton(icon: Icons.cleaning_services, tooltip: '整理文本', onPressed: onCleanText),
            _ToolButton(icon: Icons.find_replace, tooltip: '查找替换', onPressed: onFindReplace),
            const SizedBox(width: 4),
          ],

          _ToolButton(
            icon: isDarkTheme ? Icons.light_mode : Icons.dark_mode,
            tooltip: isDarkTheme ? '亮色主题' : '暗色主题',
            onPressed: onToggleTheme,
          ),

          if (width >= 1200) ...[
            const SizedBox(width: 4),
            _ToolButton(
              icon: Icons.settings,
              tooltip: '设置',
              isActive: settingsPanelOpen,
              onPressed: onToggleSettings,
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;

  const _ToolButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
          ),
          child: Icon(icon, size: 20, color: isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
