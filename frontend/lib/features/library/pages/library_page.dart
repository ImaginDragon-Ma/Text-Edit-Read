import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../bloc/library_bloc.dart';
import '../widgets/nav_sidebar.dart';
import '../widgets/file_card.dart';
import '../../editor/bloc/editor_bloc.dart';
import '../../editor/pages/editor_page.dart';
import '../../../shared/theme/colors.dart';

/// Library page — file manager / bookshelf view (Koodo Reader style)
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LibraryView();
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LibraryBloc, LibraryState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Row(
            children: [
              NavSidebar(
                selectedFilter: state.filter,
                onFilterChanged: (f) => context.read<LibraryBloc>().add(SetViewFilter(f)),
                onImportFile: () => _importFile(context),
                allCount: state.allCount,
                favoriteCount: state.favoriteCount,
                recentCount: state.recentCount,
                trashCount: state.trashCount,
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context, state),
                    Expanded(child: _buildContent(context, state)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, LibraryState state) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search, size: 18, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索文件...',
                        hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                      onChanged: (q) => context.read<LibraryBloc>().add(SearchFiles(q)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ToolBtn(icon: Icons.refresh, tooltip: '刷新', onPressed: () {
            context.read<LibraryBloc>().add(const LoadLibrary());
          }),
          _ToolBtn(icon: Icons.upload_file, tooltip: '导入', onPressed: () => _importFile(context)),
          _ToolBtn(icon: Icons.light_mode, tooltip: '主题', onPressed: () {
            context.read<EditorBloc>().add(const ToggleTheme());
          }),
          _ToolBtn(icon: Icons.settings, tooltip: '设置', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LibraryState state) {
    final theme = Theme.of(context);
    final files = state.filteredFiles;

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              state.filter == LibraryFilter.trash ? '回收站是空的' : '还没有文件',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 8),
            if (state.filter == LibraryFilter.all)
              TextButton.icon(
                onPressed: () => _importFile(context),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('导入文件'),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisExtent: 220,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return FileCard(
            file: file,
            onTap: () => _openFile(context, file),
            onFavoriteTap: () => context.read<LibraryBloc>().add(ToggleFavorite(file.filePath)),
            onDeleteTap: () => context.read<LibraryBloc>().add(DeleteFile(file.filePath)),
          );
        },
      ),
    );
  }

  Future<void> _importFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'text'],
    );
    if (result != null && result.files.single.path != null) {
      final picked = result.files.single;
      final content = picked.bytes != null ? String.fromCharCodes(picked.bytes!) : '';
      context.read<LibraryBloc>().add(ImportFile(
        filePath: picked.path!,
        fileName: picked.name,
        content: content,
        fileSize: picked.size,
        lastModified: DateTime.now(),
      ));
    }
  }

  void _openFile(BuildContext context, LibraryFile file) {
    context.read<EditorBloc>().add(LoadFile(file.filePath));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditorPage()),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolBtn({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
