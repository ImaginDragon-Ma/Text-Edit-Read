import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;
  final String? hint;
  final bool initiallyExpanded;
  final double collapsedWidth;

  const AppSearchBar({
    super.key,
    this.onSearch,
    this.onClear,
    this.hint = '搜索...',
    this.initiallyExpanded = false,
    this.collapsedWidth = 40,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_expanded) {
      return IconButton(
        icon: const Icon(Icons.search, size: 20),
        tooltip: '搜索',
        onPressed: () {
          setState(() => _expanded = true);
          _focusNode.requestFocus();
        },
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: 280,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onSearch,
              onSubmitted: widget.onSearch,
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear?.call();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
