import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/find_replace_bloc.dart';

/// 查找对话框
///
/// 搜索框 + 上一个/下一个按钮 + 匹配计数 + 黄色高亮信息
class FindDialog extends StatefulWidget {
  final String initialText;
  final int cursorPosition;
  final ValueChanged<int>? onJumpToMatch;

  const FindDialog({
    super.key,
    required this.initialText,
    this.cursorPosition = 0,
    this.onJumpToMatch,
  });

  @override
  State<FindDialog> createState() => FindDialogState();
}

class FindDialogState extends State<FindDialog> {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
      // If text is selected in editor, use it as search term
      if (widget.cursorPosition >= 0) {
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _doFindNext() {
    final term = _searchController.text;
    if (term.isEmpty) return;
    final bloc = context.read<FindReplaceBloc>();
    final state = bloc.state;
    final startPos = (state.matchPosition ?? widget.cursorPosition) +
        (state.matchLength ?? term.length);
    bloc.add(FindNext(
      text: widget.initialText,
      searchTerm: term,
      startPosition: startPos,
    ));
  }

  void _doFindPrevious() {
    final term = _searchController.text;
    if (term.isEmpty) return;
    final bloc = context.read<FindReplaceBloc>();
    final state = bloc.state;
    final startPos = state.matchPosition ?? widget.cursorPosition;
    bloc.add(FindPrevious(
      text: widget.initialText,
      searchTerm: term,
      startPosition: startPos,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FindReplaceBloc(),
      child: BlocBuilder<FindReplaceBloc, FindReplaceState>(
        builder: (context, state) {
          // Notify parent of match position changes
          if (state.matchPosition != null && widget.onJumpToMatch != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onJumpToMatch!(state.matchPosition!);
            });
          }

          return AlertDialog(
            title: const Text('查找'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '输入搜索词...',
                    suffixIcon: state.searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<FindReplaceBloc>().add(const ClearSearch());
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _doFindNext(),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<FindReplaceBloc>().add(FindNext(
                        text: widget.initialText,
                        searchTerm: value,
                        startPosition: widget.cursorPosition,
                      ));
                    } else {
                      context.read<FindReplaceBloc>().add(const ClearSearch());
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      state.totalMatches > 0
                          ? '${state.currentMatchIndex + 1} / ${state.totalMatches}'
                          : state.searchTerm.isNotEmpty
                              ? '无匹配'
                              : '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (state.error != null)
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _doFindPrevious,
                child: const Text('上一个'),
              ),
              ElevatedButton(
                onPressed: _doFindNext,
                child: const Text('下一个'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Convenience method to show the dialog
  static Future<void> show(
    BuildContext context, {
    required String text,
    int cursorPosition = 0,
    ValueChanged<int>? onJumpToMatch,
  }) {
    return showDialog(
      context: context,
      builder: (_) => FindDialog(
        initialText: text,
        cursorPosition: cursorPosition,
        onJumpToMatch: onJumpToMatch,
      ),
    );
  }
}
