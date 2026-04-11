import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../editor/bloc/editor_bloc.dart';
import '../../chapter_nav/bloc/chapter_nav_bloc.dart';
import '../../chapter_nav/widgets/toc_panel.dart';
import '../../../shared/theme/colors.dart';

/// Reader page — read-only view with chapter navigation and progress
class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChapterNavBloc()),
      ],
      child: const _ReaderView(),
    );
  }
}

class _ReaderView extends StatelessWidget {
  const _ReaderView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return BlocBuilder<EditorBloc, EditorState>(
      builder: (context, state) {
        return Scaffold(
          body: Row(
            children: [
              // Left: chapter sidebar (collapsible on mobile)
              if (!isMobile)
                Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    border: Border(right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
                  ),
                  child: TocPanel(
                    onJumpToPosition: (pos) {
                      // TODO: scroll to position
                    },
                  ),
                ),

              // Center: reading area
              Expanded(
                child: Column(
                  children: [
                    _buildReaderToolbar(context, state),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: width * 0.6),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                            child: SelectableText(
                              state.text.isEmpty ? '打开文件开始阅读...' : state.text,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.8,
                                color: theme.colorScheme.onSurface,
                                fontFamily: 'Noto Sans SC',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildProgressBar(context, state),
                  ],
                ),
              ),
            ],
          ),
          drawer: isMobile
              ? Drawer(
                  child: TocPanel(
                    onJumpToPosition: (pos) {},
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildReaderToolbar(BuildContext context, EditorState state) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            tooltip: '返回文件库',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            state.currentFile?.fileName ?? '阅读模式',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.bookmark_border, size: 20), tooltip: '书签', onPressed: () {}),
          IconButton(icon: const Icon(Icons.fullscreen, size: 20), tooltip: '全屏', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, EditorState state) {
    final theme = Theme.of(context);
    final progress = state.totalChapters > 0
        ? ((state.currentChapter + 1) / state.totalChapters).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Text(
            state.totalChapters > 0
                ? '第 ${state.currentChapter + 1} / ${state.totalChapters} 章'
                : '',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
