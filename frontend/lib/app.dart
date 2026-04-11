import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/editor/bloc/editor_bloc.dart';
import 'features/editor/pages/editor_page.dart';
import 'shared/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditorBloc(),
      child: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Text Edit Read',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            home: const EditorPage(),
          );
        },
      ),
    );
  }
}
