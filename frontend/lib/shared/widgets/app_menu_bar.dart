import 'package:flutter/material.dart';

class AppMenuBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenFile;
  final VoidCallback onSaveFile;
  final VoidCallback onSaveFileAs;
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const AppMenuBar({
    super.key,
    required this.onOpenFile,
    required this.onSaveFile,
    required this.onSaveFileAs,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Mobile: hide menu bar, use AppBar overflow menu
    if (width < 800) {
      return AppBar(
        title: const Text('Text Edit Read'),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open), onPressed: onOpenFile),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'save': onSaveFile();
                case 'save_as': onSaveFileAs();
                case 'theme': onToggleTheme();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'save', child: Text('保存')),
              const PopupMenuItem(value: 'save_as', child: Text('另存为')),
              const PopupMenuItem(value: 'theme', child: Text('切换主题')),
            ],
          ),
        ],
      );
    }

    // Desktop: full menu bar
    return AppBar(
      title: const Text('Text Edit Read'),
      actions: [
        _MenuButton(label: '文件', items: [
          _MenuItem('打开文件', onOpenFile),
          _MenuItem('保存', onSaveFile),
          _MenuItem('另存为', onSaveFileAs),
        ]),
        _MenuButton(label: '视图', items: [
          _MenuItem(isDarkTheme ? '亮色主题' : '暗色主题', onToggleTheme),
        ]),
        _MenuButton(label: '帮助', items: [
          _MenuItem('关于', () => showAboutDialog(
            context: context,
            applicationName: 'Text Edit Read',
            applicationVersion: '0.1.0',
          )),
        ]),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final List<_MenuItem> items;

  const _MenuButton({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        for (final item in items) {
          if (item.label == value) {
            item.onTap();
            break;
          }
        }
      },
      itemBuilder: (_) => items
          .map((i) => PopupMenuItem(value: i.label, child: Text(i.label)))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final VoidCallback onTap;
  _MenuItem(this.label, this.onTap);
}
