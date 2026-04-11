import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_bloc.dart';

/// 设置页面
///
/// 字体大小滑块、编码选择、主题切换
/// 移动端用独立页面，桌面端可在菜单栏打开
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── 字体大小 ──
              _SectionHeader(title: '字体大小'),
              _FontSlider(state: state),
              const SizedBox(height: 24),

              // ── 默认编码 ──
              _SectionHeader(title: '默认编码'),
              _EncodingSelector(state: state),
              const SizedBox(height: 24),

              // ── 主题 ──
              _SectionHeader(title: '主题'),
              _ThemeSelector(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _FontSlider extends StatelessWidget {
  final SettingsState state;
  const _FontSlider({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('编辑器字体'),
            Text(
              '${state.fontSize.round()} px',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: state.fontSize,
          min: 12,
          max: 72,
          divisions: 12,
          label: '${state.fontSize.round()} px',
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateFontSize(value));
          },
        ),
        // Preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '预览文字 Preview',
            style: TextStyle(fontSize: state.fontSize),
          ),
        ),
      ],
    );
  }
}

class _EncodingSelector extends StatelessWidget {
  final SettingsState state;
  const _EncodingSelector({required this.state});

  static const _encodings = ['utf-8', 'gb18030', 'gbk', 'big5', 'shift_jis'];

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: _encodings.map((e) => ButtonSegment(value: e, label: Text(e.toUpperCase()))).toList(),
      selected: {state.encoding},
      onSelectionChanged: (selected) {
        context.read<SettingsBloc>().add(UpdateEncoding(selected.first));
      },
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final SettingsState state;
  const _ThemeSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeCard(
            label: '亮色',
            icon: Icons.light_mode,
            isSelected: state.theme == 'light',
            onTap: () => _setTheme(context, 'light'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ThemeCard(
            label: '暗色',
            icon: Icons.dark_mode,
            isSelected: state.theme == 'dark',
            onTap: () => _setTheme(context, 'dark'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ThemeCard(
            label: '跟随系统',
            icon: Icons.brightness_auto,
            isSelected: state.theme == 'system',
            onTap: () => _setTheme(context, 'system'),
          ),
        ),
      ],
    );
  }

  void _setTheme(BuildContext context, String theme) {
    context.read<SettingsBloc>().add(SetTheme(theme));
  }
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}
