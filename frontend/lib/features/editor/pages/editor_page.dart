import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/editor_bloc.dart';
import '../../chapter_nav/bloc/chapter_nav_bloc.dart';
import '../../chapter_nav/widgets/toc_panel.dart';
import '../../../shared/widgets/zoomable_text_field.dart';
import '../../../shared/widgets/file_tab_bar.dart';
import '../../../shared/widgets/status_bar.dart';
import '../../../shared/widgets/app_menu_bar.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChapterNavBloc()),
      ],
      child: const _EditorView(),
    );
  }
}

class _EditorView extends StatefulWidget {
  const _EditorView();

  @override
  State<_EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<_EditorView> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _updatingFromBloc = false;
  bool _sidebarCollapsed = false;
  bool _settingsPanelOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditorBloc, EditorState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        if (!_updatingFromBloc && state.currentFile != null && _controller.text != state.text) {
          _updatingFromBloc = true;
          _controller.text = state.text;
          _updatingFromBloc = false;
        }

        final width = MediaQuery.of(context).size.width;
        final isMobile = width < 600;
        final isDesktop = width >= 1200;

        return Scaffold(
          body: Column(
            children: [
              // Top bar
              AppMenuBar(
                onOpenFile: () => context.read<EditorBloc>().add(const OpenFilePicker()),
                onSaveFile: () => context.read<EditorBloc>().add(const SaveFile()),
                onSaveFileAs: () => _showSaveAsDialog(context),
                onToggleTheme: () => context.read<EditorBloc>().add(const ToggleTheme()),
                onCleanText: () {},
                onFindReplace: () {},
                onToggleSidebar: isDesktop ? _toggleSidebar : null,
                onToggleSettings: isDesktop ? _toggleSettings : null,
                isDarkTheme: state.isDarkTheme,
                sidebarCollapsed: _sidebarCollapsed,
                settingsPanelOpen: _settingsPanelOpen,
              ),

              // Main content area
              Expanded(
                child: isMobile
                    ? _buildMobileLayout(context, state)
                    : _buildDesktopLayout(context, state, isDesktop),
              ),

              // Status bar
              StatusBar(
                currentChapter: state.currentChapter,
                totalChapters: state.totalChapters,
                wordCount: state.wordCount,
                selectedCharCount: state.selectedCharCount,
              ),
            ],
          ),
          floatingActionButton: state.currentFile == null
              ? FloatingActionButton.extended(
                  onPressed: () => context.read<EditorBloc>().add(const OpenFilePicker()),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('打开文件'),
                )
              : null,
          drawer: isMobile ? _buildDrawer(context, state) : null,
        );
      },
    );
  }

  // ── Mobile Layout ──
  Widget _buildMobileLayout(BuildContext context, EditorState state) {
    return Column(
      children: [
        FileTabBar(
          openFiles: state.openFiles,
          currentFile: state.currentFile,
          onTabSwitch: (p) => context.read<EditorBloc>().add(SwitchTab(p)),
          onTabClose: (p) => context.read<EditorBloc>().add(CloseTab(p)),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ZoomableTextField(
                controller: _controller,
                focusNode: _focusNode,
                fontSize: state.fontSize,
                onFontSizeChanged: (s) => context.read<EditorBloc>().add(SetFontSize(s)),
                onCursorPositionChanged: (pos) {
                  if (!_updatingFromBloc) {
                    context.read<EditorBloc>().add(CursorChanged(position: pos));
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Desktop/Tablet Layout ──
  Widget _buildDesktopLayout(BuildContext context, EditorState state, bool isDesktop) {
    final bloc = context.read<EditorBloc>();
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final double sidebarExpanded = isDesktop ? 260 : 200;

    return Row(
      children: [
        // ── Sidebar (frosted glass, collapsible) ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: _sidebarCollapsed ? 56 : sidebarExpanded,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
                  border: Border(
                    right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
                  ),
                ),
                child: _sidebarCollapsed
                    ? _buildCollapsedSidebar(context)
                    : _buildExpandedSidebar(context),
              ),
            ),
          ),
        ),

        // ── Main editor area ──
        Expanded(
          child: Column(
            children: [
              FileTabBar(
                openFiles: state.openFiles,
                currentFile: state.currentFile,
                onTabSwitch: (p) => bloc.add(SwitchTab(p)),
                onTabClose: (p) => bloc.add(CloseTab(p)),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width * 0.65),
                    child: ZoomableTextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      fontSize: state.fontSize,
                      onFontSizeChanged: (s) => bloc.add(SetFontSize(s)),
                      onCursorPositionChanged: (pos) {
                        if (!_updatingFromBloc) {
                          bloc.add(CursorChanged(position: pos));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Settings panel (desktop only, slides from right) ──
        if (isDesktop)
          AnimatedSlide(
            offset: Offset(_settingsPanelOpen ? 0 : 1, 0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: _settingsPanelOpen ? 320 : 0,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border: Border(
                  left: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
              ),
              child: _settingsPanelOpen
                  ? _buildSettingsPanel(context, state)
                  : const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  // ── Sidebar ──
  Widget _buildExpandedSidebar(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
          child: Row(
            children: [
              Icon(Icons.menu_book, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('章节目录', style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _toggleSidebar,
                tooltip: '折叠',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: TocPanel(
            onJumpToPosition: (pos) {
              // TODO: scroll editor to position
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedSidebar(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 12),
        IconButton(
          icon: Icon(Icons.menu_book, color: theme.colorScheme.primary, size: 22),
          onPressed: _toggleSidebar,
          tooltip: '展开目录',
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Settings panel ──
  Widget _buildSettingsPanel(BuildContext context, EditorState state) {
    final theme = Theme.of(context);
    final bloc = context.read<EditorBloc>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('设置', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _toggleSettings,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Font size
        Text('字号', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () => bloc.add(SetFontSize(state.fontSize - 2)),
            ),
            Expanded(
              child: Slider(
                value: state.fontSize,
                min: 12,
                max: 32,
                divisions: 10,
                label: '${state.fontSize.toInt()}',
                onChanged: (v) => bloc.add(SetFontSize(v)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => bloc.add(SetFontSize(state.fontSize + 2)),
            ),
            SizedBox(
              width: 30,
              child: Text('${state.fontSize.toInt()}', style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Theme
        Text('主题', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('亮色'), icon: Icon(Icons.light_mode, size: 18)),
            ButtonSegment(value: true, label: Text('暗色'), icon: Icon(Icons.dark_mode, size: 18)),
          ],
          selected: {state.isDarkTheme},
          onSelectionChanged: (_) => bloc.add(const ToggleTheme()),
        ),
        const SizedBox(height: 20),

        Text('关于', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('Text Edit Read v0.1.0', style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )),
      ],
    );
  }

  // ── Mobile drawer ──
  Widget _buildDrawer(BuildContext context, EditorState state) {
    final theme = Theme.of(context);
    final bloc = context.read<EditorBloc>();

    return Drawer(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.auto_stories, color: theme.colorScheme.primary, size: 32),
                      const SizedBox(height: 8),
                      Text('Text Edit Read',
                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('打开文件'),
                  onTap: () { Navigator.pop(context); bloc.add(const OpenFilePicker()); },
                ),
                ListTile(
                  leading: const Icon(Icons.save),
                  title: const Text('保存'),
                  onTap: () { Navigator.pop(context); bloc.add(const SaveFile()); },
                ),
                ListTile(
                  leading: const Icon(Icons.save_as),
                  title: const Text('另存为'),
                  onTap: () { Navigator.pop(context); _showSaveAsDialog(context); },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cleaning_services),
                  title: const Text('整理文本'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.find_replace),
                  title: const Text('查找替换'),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(state.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
                  title: Text(state.isDarkTheme ? '亮色主题' : '暗色主题'),
                  onTap: () { Navigator.pop(context); bloc.add(const ToggleTheme()); },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSidebar() => setState(() => _sidebarCollapsed = !_sidebarCollapsed);
  void _toggleSettings() => setState(() => _settingsPanelOpen = !_settingsPanelOpen);

  Future<void> _showSaveAsDialog(BuildContext context) async {
    context.read<EditorBloc>().add(const SaveFileAs('/tmp/new_file.txt'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('另存为功能将在文件选择器集成后完善')),
    );
  }
}
