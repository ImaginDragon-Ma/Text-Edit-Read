import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/editor_bloc.dart';
import '../../shared/widgets/zoomable_text_field.dart';
import '../../shared/widgets/file_tab_bar.dart';
import '../../shared/widgets/status_bar.dart';
import '../../shared/widgets/app_menu_bar.dart';
import '../../core/models/text_file.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EditorView();
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
        // Sync text from bloc to controller when file changes
        if (!_updatingFromBloc && state.currentFile != null && _controller.text != state.text) {
          _updatingFromBloc = true;
          _controller.text = state.text;
          _updatingFromBloc = false;
        }

        final width = MediaQuery.of(context).size.width;

        return Scaffold(
          appBar: AppMenuBar(
            onOpenFile: () => context.read<EditorBloc>().add(const OpenFilePicker()),
            onSaveFile: () => context.read<EditorBloc>().add(const SaveFile()),
            onSaveFileAs: () => _showSaveAsDialog(context),
            onToggleTheme: () => context.read<EditorBloc>().add(const ToggleTheme()),
            isDarkTheme: state.isDarkTheme,
          ),
          drawer: width < 800 ? _buildDrawer(context, state) : null,
          body: Column(
            children: [
              FileTabBar(
                openFiles: state.openFiles,
                currentFile: state.currentFile,
                onTabSwitch: (path) => context.read<EditorBloc>().add(SwitchTab(path)),
                onTabClose: (path) => context.read<EditorBloc>().add(CloseTab(path)),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ZoomableTextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      fontSize: state.fontSize,
                      onFontSizeChanged: (s) =>
                          context.read<EditorBloc>().add(SetFontSize(s)),
                      onCursorPositionChanged: (pos) {
                        if (!_updatingFromBloc) {
                          context.read<EditorBloc>().add(CursorChanged(position: pos));
                        }
                      },
                      onSelectionStartChanged: (start) {},
                      onSelectionEndChanged: (end) {},
                    ),
                  ),
                ),
              ),
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
                  onPressed: () =>
                      context.read<EditorBloc>().add(const OpenFilePicker()),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('打开文件'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, EditorState state) {
    final bloc = context.read<EditorBloc>();
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1976D2)),
            child: Text('Text Edit Read',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('打开文件'),
            onTap: () {
              Navigator.pop(context);
              bloc.add(const OpenFilePicker());
            },
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('保存'),
            onTap: () {
              Navigator.pop(context);
              bloc.add(const SaveFile());
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_as),
            title: const Text('另存为'),
            onTap: () {
              Navigator.pop(context);
              _showSaveAsDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(state.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            title: Text(state.isDarkTheme ? '亮色主题' : '暗色主题'),
            onTap: () {
              Navigator.pop(context);
              bloc.add(const ToggleTheme());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSaveAsDialog(BuildContext context) async {
    // Use file_picker for save-as
    final bloc = context.read<EditorBloc>();
    // Trigger via bloc or directly
    bloc.add(const SaveFileAs('/tmp/new_file.txt'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('另存为功能将在文件选择器集成后完善')),
    );
  }
}
