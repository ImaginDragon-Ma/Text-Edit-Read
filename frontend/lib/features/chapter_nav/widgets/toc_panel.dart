import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chapter_nav_bloc.dart';
import 'chapter_list_item.dart';

/// 侧边栏目录面板
///
/// 可折叠、点击跳转、双击编辑标题
/// 桌面端显示为侧边栏，移动端为 Drawer 内容
class TocPanel extends StatelessWidget {
  final ValueChanged<int>? onJumpToPosition;

  const TocPanel({super.key, this.onJumpToPosition});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChapterNavBloc, ChapterNavState>(
      builder: (context, state) {
        if (state.chapters.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('未检测到章节', style: TextStyle(fontSize: 13)),
            ),
          );
        }

        if (state.isCollapsed) {
          return _CollapsedToc(
            count: state.chapters.length,
            onTap: () => context.read<ChapterNavBloc>().add(
              const ToggleCollapse(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '目录 (${state.chapters.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 18),
                    onPressed: () => context.read<ChapterNavBloc>().add(
                      const ToggleCollapse(),
                    ),
                    tooltip: '折叠',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: state.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = state.chapters[index];
                  return ChapterListItem(
                    chapter: chapter,
                    index: index,
                    isActive: index == state.currentChapterIndex,
                    onTap: () {
                      context.read<ChapterNavBloc>().add(JumpToChapter(index));
                      onJumpToPosition?.call(chapter.startIndex);
                    },
                    onTitleEdited: (newTitle) {
                      context.read<ChapterNavBloc>().add(
                        EditChapterTitle(chapterIndex: index, newTitle: newTitle),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 折叠状态的迷你目录
class _CollapsedToc extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _CollapsedToc({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.list_alt, size: 20),
            const SizedBox(height: 4),
            Text('$count章', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
