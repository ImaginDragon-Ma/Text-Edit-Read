import 'package:flutter/material.dart';

import '../../../core/models/chapter.dart';

/// 单个章节条目
///
/// 支持点击跳转、双击编辑标题
class ChapterListItem extends StatefulWidget {
  final Chapter chapter;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<String> onTitleEdited;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.index,
    required this.isActive,
    required this.onTap,
    required this.onTitleEdited,
  });

  @override
  State<ChapterListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<ChapterListItem> {
  bool _isEditing = false;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.chapter.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    _titleController.text = widget.chapter.title;
    _titleController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _titleController.text.length,
    );
  }

  void _finishEditing() {
    if (_isEditing) {
      final newTitle = _titleController.text.trim();
      if (newTitle.isNotEmpty && newTitle != widget.chapter.title) {
        widget.onTitleEdited(newTitle);
      }
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (_isEditing) {
          _finishEditing();
        } else {
          widget.onTap();
        }
      },
      onDoubleTap: _startEditing,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isActive
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : null,
          border: Border(
            left: BorderSide(
              color: widget.isActive
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: _isEditing
            ? TextField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _finishEditing(),
                onEditingComplete: _finishEditing,
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.chapter.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${widget.chapter.charCount}字',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
