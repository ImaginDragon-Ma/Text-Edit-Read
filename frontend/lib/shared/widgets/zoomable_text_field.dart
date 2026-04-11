import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZoomableTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<int> onCursorPositionChanged;
  final ValueChanged<int>? onSelectionStartChanged;
  final ValueChanged<int>? onSelectionEndChanged;

  const ZoomableTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.onCursorPositionChanged,
    this.onSelectionStartChanged,
    this.onSelectionEndChanged,
  });

  @override
  State<ZoomableTextField> createState() => _ZoomableTextFieldState();
}

class _ZoomableTextFieldState extends State<ZoomableTextField> {
  double _baseScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (_) => _baseScaleFactor = 1.0,
      onScaleUpdate: (details) {
        if (details.pointerCount >= 2) {
          final scale = details.scale / _baseScaleFactor;
          _baseScaleFactor = details.scale;
          final newSize = widget.fontSize * scale;
          widget.onFontSizeChanged(newSize.clamp(12.0, 72.0));
        }
      },
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: TextStyle(fontSize: widget.fontSize),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '打开文件开始编辑...',
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (_) => _notifyCursor(),
        onTap: _notifyCursor,
      ),
    );
  }

  void _notifyCursor() {
    final sel = widget.controller.selection;
    if (sel.isValid) {
      widget.onCursorPositionChanged(sel.baseOffset);
      widget.onSelectionStartChanged?.call(sel.start);
      widget.onSelectionEndChanged?.call(sel.end);
    }
  }
}
