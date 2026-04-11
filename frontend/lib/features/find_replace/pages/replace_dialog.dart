import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/find_replace_bloc.dart';

/// 替换对话框
///
/// 模式选择：全部替换 / 双引号外替换
/// 替换完成后返回新文本
class ReplaceDialog extends StatefulWidget {
  final String initialText;
  final String? initialSearchTerm;
  final ValueChanged<String> onReplaced;

  const ReplaceDialog({
    super.key,
    required this.initialText,
    this.initialSearchTerm,
    required this.onReplaced,
  });

  @override
  State<ReplaceDialog> createState() => _ReplaceDialogState();
}

class _ReplaceDialogState extends State<ReplaceDialog> {
  late TextEditingController _searchController;
  late TextEditingController _replaceController;
  bool _excludeQuotes = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchTerm ?? '');
    _replaceController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  void _doReplace() {
    final oldWord = _searchController.text;
    final newWord = _replaceController.text;
    if (oldWord.isEmpty) return;

    if (_excludeQuotes) {
      context.read<FindReplaceBloc>().add(ReplaceExceptQuotes(
        text: widget.initialText,
        oldWord: oldWord,
        newWord: newWord,
      ));
    } else {
      context.read<FindReplaceBloc>().add(ReplaceAll(
        text: widget.initialText,
        oldWord: oldWord,
        newWord: newWord,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FindReplaceBloc(),
      child: BlocListener<FindReplaceBloc, FindReplaceState>(
        listener: (context, state) {
          // When replace is done, notify parent and close
          if (state.replacedText != null) {
            widget.onReplaced(state.replacedText!);
            Navigator.of(context).pop();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: BlocBuilder<FindReplaceBloc, FindReplaceState>(
          builder: (context, state) {
            return AlertDialog(
              title: const Text('查找与替换'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: '查找',
                      hintText: '输入要替换的词...',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _replaceController,
                    decoration: const InputDecoration(
                      labelText: '替换为',
                      hintText: '输入替换后的词...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('替换模式:', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('全部替换')),
                          ButtonSegment(value: true, label: Text('引号外')),
                        ],
                        selected: {_excludeQuotes},
                        onSelectionChanged: (selected) {
                          setState(() => _excludeQuotes = selected.first);
                        },
                      ),
                    ],
                  ),
                  if (state.isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: state.isProcessing ? null : _doReplace,
                  child: const Text('替换'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Convenience method to show the dialog
  static Future<void> show(
    BuildContext context, {
    required String text,
    String? initialSearchTerm,
    required ValueChanged<String> onReplaced,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ReplaceDialog(
        initialText: text,
        initialSearchTerm: initialSearchTerm,
        onReplaced: onReplaced,
      ),
    );
  }
}
