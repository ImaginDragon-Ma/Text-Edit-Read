# Text-Edit-Read Flutter 重构需求分析报告

> 生成时间：2026-04-11
> 基于：v0.2.0（PyQt5 分层架构版本）

---

## 一、现有功能清单

### 1.1 文件操作
| 功能 | 说明 | 涉及文件 |
|------|------|----------|
| 打开文件 | 文件选择对话框，自动检测编码（chardet），支持重复打开检测 | `core/file_handler.py`, `ui/main_window.py` |
| 保存文件 | 保存到原路径，默认 UTF-8 | `core/file_handler.py`, `ui/main_window.py` |
| 另存为 | 新路径保存 | `ui/main_window.py` |
| 编码检测 | 采样 4096 字节，置信度阈值 0.7，GB2312→gb18030 兼容映射 | `core/file_handler.py` |
| 多文件标签 | 标签栏管理，可切换/关闭，支持拖拽排序 | `ui/main_window.py` |

### 1.2 文本处理（核心业务）
| 功能 | 说明 | 涉及文件 |
|------|------|----------|
| 清理文本 | 删除开头空格、空白段落、分离章节标题、章节间空行、段落缩进（全角空格） | `core/text_processor.py` |
| 查找文本 | 正则转义匹配，支持向前/向后查找，返回位置和匹配文本 | `core/text_processor.py` |
| 全部替换 | 逐行替换，返回替换计数 | `core/text_processor.py` |
| 双引号外替换 | 正则匹配中英文引号内/外内容，仅替换引号外 | `core/text_processor.py` |
| 撤销操作 | 基于 QTextDocument 撤销栈 | `ui/main_window.py` |

### 1.3 章节导航
| 功能 | 说明 | 涉及文件 |
|------|------|----------|
| 章节检测 | 正则匹配 `序章` / `第X章`（中文数字+阿拉伯数字） | `ui/main_window.py` |
| 侧边栏目录 | 可折叠目录列表，点击跳转，双击编辑标题同步到文本 | `ui/main_window.py` |
| 章节定位 | 光标跟踪当前章节，状态栏显示 `章节: X/Y` | `ui/main_window.py` |
| 章节字数统计 | 当前章节字数 / 总字数 | `ui/main_window.py` |

### 1.4 UI 交互
| 功能 | 说明 | 涉及文件 |
|------|------|----------|
| 字体缩放 | Ctrl+滚轮，范围 6-36pt，步长 2 | `ui/widgets/zoom_text_edit.py` |
| 查找对话框 | 独立弹窗，查找上/下一个，黄色高亮 | `ui/dialogs/find_dialog.py` |
| 替换对话框 | 独立弹窗，模式选择（全部/引号外） | `ui/dialogs/replace_dialog.py` |
| 状态栏 | 章节信息、操作提示（3秒自动消失）、选中字数、总字数 | `ui/main_window.py` |
| 快捷键 | Ctrl+S 保存、Ctrl+Shift+S 另存为、Ctrl+Z 撤销 | `ui/main_window.py` |

---

## 二、核心业务逻辑清单（可复用的 Python 逻辑）

以下逻辑**与 UI 无关**，可直接迁移为 FastAPI 后端服务或 Dart 端重写：

### 2.1 文本处理（纯函数，最核心）

| 函数 | 输入 | 输出 | 复用性 |
|------|------|------|--------|
| `clean_text(text)` | 原始文本 | 格式化文本 | ⭐⭐⭐ 高 |
| `find_text(text, term, pos, dir)` | 文本+查询参数 | (位置, 匹配文本) | ⭐⭐⭐ 高 |
| `replace_all_word(lines, old, new)` | 行列表+替换参数 | (新行列表, 计数) | ⭐⭐⭐ 高 |
| `replace_except_in_quotes(lines, old, new)` | 行列表+替换参数 | (新行列表, 计数) | ⭐⭐⭐ 高 |
| `_remove_all_leading_spaces(text)` | 文本 | 文本 | ⭐⭐ 中 |
| `_remove_empty_paragraphs(text)` | 文本 | 文本 | ⭐⭐ 中 |
| `_separate_chapter_titles(text)` | 文本 | 文本 | ⭐⭐⭐ 高 |
| `_add_chapter_spacing(text)` | 文本 | 文本 | ⭐⭐ 中 |
| `_add_paragraph_indent(text)` | 文本 | 文本 | ⭐⭐ 中 |

### 2.2 文件操作

| 函数 | 输入 | 输出 | 复用性 |
|------|------|------|--------|
| `detect_encoding(file_path)` | 文件路径 | 编码名 | ⭐⭐⭐ 高 |
| `read_file(file_path, encoding?)` | 路径+可选编码 | 文本内容 | ⭐⭐⭐ 高 |
| `save_file(file_path, content, encoding)` | 路径+内容+编码 | None | ⭐⭐⭐ 高 |

### 2.3 正则表达式常量

```
chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)'
quote_pattern = r'"[^"]*"|"[^"]*"|[^"""]+'
```

---

## 三、Flutter 重构目标

| 平台 | 优先级 | 特殊考虑 |
|------|--------|----------|
| **手机 App**（Android/iOS） | P0 | 触摸交互、文件选择（权限）、响应式布局 |
| **网页**（Web） | P1 | 文件上传/下载替代本地文件系统、无需安装 |
| **桌面**（Windows/macOS/Linux） | P2 | 本地文件操作、菜单栏/快捷键、多窗口标签 |

### 核心原则
1. **一套代码三端运行**（Flutter cross-platform）
2. **业务逻辑与 UI 完全解耦**
3. **保留所有现有功能**
4. **新增：云端同步、暗色主题、实时预览**

---

## 四、建议的技术架构

```
┌─────────────────────────────────────────────┐
│              Flutter App (Dart)              │
│  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │
│  │  Mobile   │ │   Web    │ │   Desktop    │ │
│  │  (Android │ │ (Canvas/ │ │ (Windows/    │ │
│  │  /iOS)    │ │  HTML)   │ │  macOS/Linux)│ │
│  └─────┬─────┘ └─────┬────┘ └──────┬───────┘ │
│        └──────────────┼─────────────┘         │
│                    │                          │
│  ┌─────────────────▼─────────────────────┐   │
│  │          Presentation Layer           │   │
│  │   (Screens, Widgets, BLoC/Cubit)      │   │
│  └─────────────────┬─────────────────────┘   │
│                    │                          │
│  ┌─────────────────▼─────────────────────┐   │
│  │          Domain Layer (Service)        │   │
│  │   TextProcessor, FileHandler, etc.     │   │
│  └──────────┬──────────────┬──────────────┘   │
│             │              │                  │
│  ┌──────────▼──────┐ ┌────▼───────────────┐  │
│  │  Local Storage   │ │  FastAPI Backend    │  │
│  │  (Hive/SQLite)   │ │  (Python 核心)     │  │
│  │  文件操作/配置   │ │  高级处理/云同步    │  │
│  └─────────────────┘ └────────────────────┘  │
└─────────────────────────────────────────────┘
```

### 架构选择

| 层 | 技术选型 | 理由 |
|----|----------|------|
| 前端框架 | Flutter 3.x | 三端统一 |
| 状态管理 | flutter_bloc (Cubit) | 简单场景够用，易于测试 |
| 本地存储 | Hive（配置/缓存）+ SQLite（大文本） | 轻量高效 |
| 后端 API | FastAPI | 复用现有 Python 文本处理逻辑 |
| 通信 | REST API + WebSocket（可选实时） | 标准化 |
| 桌面文件操作 | `file_picker` + `path_provider` | Flutter 插件生态成熟 |
| Web 文件操作 | `file_selector`（浏览器 File API） | Web 端限制 |

### 策略：Dart 端为主，FastAPI 为辅

- **Dart 端**重写所有核心逻辑（文本处理、章节检测），因为逻辑简单且需离线使用
- **FastAPI 后端**提供可选的高级功能（大文件处理、AI 辅助、云同步）
- 两者功能对称，Dart 可独立运行

---

## 五、项目文件结构

```
text-edit-read/
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── .github/
│   └── copilot-instructions.md
│
├── backend/                        # FastAPI 后端（可选）
│   ├── requirements.txt
│   ├── main.py
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                # FastAPI 入口
│   │   ├── routers/
│   │   │   ├── text_processing.py  # 文本处理 API
│   │   │   └── file_operations.py  # 文件操作 API
│   │   ├── services/
│   │   │   ├── text_processor.py   # 迁移自 src/core/text_processor.py
│   │   │   └── file_handler.py     # 迁移自 src/core/file_handler.py
│   │   └── models/
│   │       └── schemas.py          # Pydantic 模型
│   └── tests/
│       └── test_api.py
│
├── docs/                           # 文档
│   ├── requirements-analysis.md    # 本文件
│   ├── api-spec.md                 # API 文档
│   └── migration-guide.md          # 迁移指南
│
└── frontend/                       # Flutter 前端
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── lib/
    │   ├── main.dart               # 应用入口
    │   ├── app.dart                # MaterialApp 配置
    │   │
    │   ├── core/                   # 领域层（纯 Dart，无 UI 依赖）
    │   │   ├── text_processor.dart
    │   │   ├── file_handler.dart
    │   │   ├── chapter_detector.dart
    │   │   ├── models/
    │   │   │   ├── text_file.dart
    │   │   │   ├── chapter.dart
    │   │   │   └── replace_result.dart
    │   │   └── constants/
    │   │       └── app_config.dart
    │   │
    │   ├── data/                   # 数据层
    │   │   ├── repositories/
    │   │   │   ├── file_repository.dart
    │   │   │   └── settings_repository.dart
    │   │   ├── services/
    │   │   │   ├── local_file_service.dart
    │   │   │   ├── api_client.dart
    │   │   │   └── api_service.dart
    │   │   └── storage/
    │   │       ├── local_storage.dart
    │   │       └── database.dart
    │   │
    │   ├── features/               # 功能模块（Feature-first）
    │   │   ├── editor/             # 文本编辑
    │   │   │   ├── bloc/
    │   │   │   │   ├── editor_bloc.dart
    │   │   │   │   ├── editor_event.dart
    │   │   │   │   └── editor_state.dart
    │   │   │   └── pages/
    │   │   │       └── editor_page.dart
    │   │   │
    │   │   ├── file_manager/       # 文件管理
    │   │   │   ├── bloc/
    │   │   │   │   ├── file_manager_bloc.dart
    │   │   │   │   ├── file_manager_event.dart
    │   │   │   │   └── file_manager_state.dart
    │   │   │   └── pages/
    │   │   │       └── file_manager_page.dart
    │   │   │
    │   │   ├── text_processing/    # 文本处理
    │   │   │   ├── bloc/
    │   │   │   │   ├── text_processing_bloc.dart
    │   │   │   │   ├── text_processing_event.dart
    │   │   │   │   └── text_processing_state.dart
    │   │   │   └── pages/
    │   │   │       └── text_processing_page.dart
    │   │   │
    │   │   ├── find_replace/       # 查找替换
    │   │   │   ├── bloc/
    │   │   │   │   └── ...
    │   │   │   └── pages/
    │   │   │       ├── find_dialog.dart
    │   │   │       └── replace_dialog.dart
    │   │   │
    │   │   ├── chapter_nav/        # 章节导航
    │   │   │   ├── bloc/
    │   │   │   │   └── ...
    │   │   │   └── widgets/
    │   │   │       ├── toc_panel.dart
    │   │   │       └── chapter_list_item.dart
    │   │   │
    │   │   └── settings/           # 设置
    │   │       ├── bloc/
    │   │       │   └── ...
    │   │       └── pages/
    │   │           └── settings_page.dart
    │   │
    │   ├── shared/                 # 共享组件
    │   │   ├── widgets/
    │   │   │   ├── zoomable_text_field.dart
    │   │   │   ├── status_bar.dart
    │   │   │   ├── file_tab_bar.dart
    │   │   │   └── app_menu_bar.dart
    │   │   └── theme/
    │   │       ├── app_theme.dart
    │   │       └── colors.dart
    │   │
    │   └── utils/                  # 工具
    │       ├── platform_utils.dart
    │       └── responsive.dart
    │
    ├── test/                       # 测试
    │   ├── core/
    │   │   ├── text_processor_test.dart
    │   │   ├── file_handler_test.dart
    │   │   └── chapter_detector_test.dart
    │   ├── features/
    │   │   └── .../
    │   └── widget/
    │       └── .../
    │
    ├── integration_test/
    │   └── app_test.dart
    │
    └── web/
        └── index.html
```

---

## 六、任务拆解

### Phase 0：项目初始化（1-2 天）

| 任务 | 目标 | 涉及文件 | 依赖 |
|------|------|----------|------|
| P0-1 | 创建 Flutter 项目，配置 pubspec.yaml | `frontend/pubspec.yaml`, `frontend/lib/main.dart` | 无 |
| P0-2 | 配置 lint 规则（flutter_lints） | `frontend/analysis_options.yaml` | P0-1 |
| P0-3 | 添加依赖：flutter_bloc, equatable, file_picker, path_provider, hive, shared_preferences | `frontend/pubspec.yaml` | P0-1 |
| P0-4 | 创建目录结构 | 所有目录 | P0-1 |
| P0-5 | 创建 FastAPI 后端项目骨架 | `backend/` | 无 |

### Phase 1：核心业务逻辑层（2-3 天）

| 任务 | 目标 | 涉及文件 | 依赖 |
|------|------|----------|------|
| P1-1 | 移植 `TextProcessor` 全部方法到 Dart | `lib/core/text_processor.dart` | P0-4 |
| P1-2 | 移植 `FileHandler` 到 Dart（编码检测用 Dart 的 charset 包） | `lib/core/file_handler.dart` | P0-4 |
| P1-3 | 提取章节检测为独立模块 | `lib/core/chapter_detector.dart` | P1-1 |
| P1-4 | 定义数据模型 | `lib/core/models/*.dart` | P0-4 |
| P1-5 | 迁移 Python 核心逻辑到 FastAPI | `backend/app/services/*.py` | P0-5 |
| P1-6 | **单元测试**：覆盖所有核心逻辑（目标覆盖率 >90%） | `test/core/*.dart` | P1-1~P1-4 |

### Phase 2：数据层（1-2 天）

| 任务 | 目标 | 涉及文件 | 依赖 |
|------|------|----------|------|
| P2-1 | 实现本地文件服务（平台适配：mobile/desktop/web） | `lib/data/services/local_file_service.dart` | P1-2 |
| P2-2 | 实现 API 客户端（Dio） | `lib/data/services/api_client.dart`, `api_service.dart` | P1-5 |
| P2-3 | 实现设置存储（Hive/SharedPreferences） | `lib/data/storage/*.dart`, `lib/data/repositories/settings_repository.dart` | P0-3 |
| P2-4 | 实现文件仓库（统一本地/远程接口） | `lib/data/repositories/file_repository.dart` | P2-1, P2-2 |

### Phase 3：编辑器核心 UI（3-4 天）

| 任务 | 目标 | 涉及文件 | 依赖 |
|------|------|----------|------|
| P3-1 | 编辑器页面 + BLoC（文本加载/编辑/保存） | `lib/features/editor/` | P2-4 |
| P3-2 | 可缩放文本输入组件（pinch-to-zoom / Ctrl+滚轮） | `lib/shared/widgets/zoomable_text_field.dart` | P0-3 |
| P3-3 | 文件标签栏（多文件切换/关闭） | `lib/shared/widgets/file_tab_bar.dart` | P3-1 |
| P3-4 | 状态栏（章节信息、字数统计、选中字数、操作提示） | `lib/shared/widgets/status_bar.dart` | P3-1 |
| P3-5 | 菜单栏（桌面端）/ 抽屉菜单（移动端） | `lib/shared/widgets/app_menu_bar.dart` | P3-1 |
| P3-6 | 主题系统（亮色/暗色） | `lib/shared/theme/*.dart` | P0-4 |

### Phase 4：功能模块（3-4 天）

| 任务 | 目标 | 涉及文件 | 依赖 |
|------|------|----------|------|
| P4-1 | 文本整理功能（调用 TextProcessor.clean_text） | `lib/features/text_processing/` | P1-1, P3-1 |
| P4-2 | 查找功能（对话框 + 高亮） | `lib/features/find_replace/` | P1-1, P3-1 |
| P4-3 | 替换功能（全部替换 + 双引号外替换） | `lib/features/find_replace/` | P1-1, P3-1 |
| P4-4 | 章节导航（侧边栏目录 + 跳转 + 编辑同步） | `lib/features/chapter_nav/` | P1-3, P3-1 |
| P4-5 | 文件管理（打开/保存/另存为） | `lib/features/file_manager/` | P2-1, P3-1 |
| P4-6 | 设置页面（字体大小、编码、主题切换） | `lib/features/settings/` | P2-3 |

### Phase 5：响应式适配与优化（2-3 天）

| 任务 | 目标 | 涉及文件 | 依赖 |
|------|------|----------|------|
| P5-1 | 响应式布局（手机竖屏单栏 / 平板双栏 / 桌面完整） | `lib/utils/responsive.dart`, 各页面 | P3~P4 |
| P5-2 | Web 端文件上传/下载适配 | `lib/data/services/local_file_service.dart` | P2-1 |
| P5-3 | 快捷键支持（桌面端） | `lib/features/editor/`, 菜单组件 | P3-5 |
| P5-4 | 性能优化（大文件虚拟滚动、防抖章节扫描） | 核心层 + 编辑器 | P3-1 |
| P5-5 | 暗色主题完善 | `lib/shared/theme/` | P3-6 |

### Phase 6：测试与发布（2-3 天）

| 任务 | 目标 | 涉及文件 | 依赖 |
|------|------|----------|------|
| P6-1 | Widget 测试（编辑器、对话框、目录面板） | `test/widget/` | P3~P4 |
| P6-2 | Integration 测试（完整编辑流程） | `integration_test/` | P3~P4 |
| P6-3 | FastAPI 后端测试 | `backend/tests/` | P1-5 |
| P6-4 | Android 构建 + 签名配置 | `android/` | P5 |
| P6-5 | iOS 构建配置（需 macOS） | `ios/` | P5 |
| P6-6 | Web 构建 + 部署 | `web/` | P5 |
| P6-7 | Desktop 构建（Windows/macOS/Linux） | 各平台目录 | P5 |

---

## 七、关键依赖包

### Flutter 前端

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.0          # 状态管理
  equatable: ^2.0.5              # 值对象比较
  file_picker: ^8.0.0            # 文件选择
  path_provider: ^2.1.0          # 路径获取
  hive: ^2.2.3                   # 本地 KV 存储
  hive_flutter: ^1.1.0           # Hive Flutter 适配
  shared_preferences: ^2.2.0     # 简单配置
  dio: ^5.4.0                    # HTTP 客户端
  super_editor: ^0.8.0           # 富文本编辑（可选，替代基础 TextField）
  google_fonts: ^6.2.0           # 字体
  url_launcher: ^6.2.0           # 打开外部链接

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0              # BLoC 测试
  mocktail: ^1.0.0               # Mock
  integration_test:
    sdk: flutter
```

### FastAPI 后端

```
fastapi>=0.110.0
uvicorn>=0.27.0
python-multipart>=0.0.9
chardet>=5.0.0
pydantic>=2.0.0
pytest>=7.0.0
httpx>=0.27.0
```

---

## 八、风险评估

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Flutter 大文本编辑性能 | 大文件（>1MB）滚动卡顿 | 虚拟滚动、分页加载、super_editor |
| Web 端文件系统受限 | 无法直接操作本地文件 | File API + 下载方式 |
| 中文编码检测准确性 | chardet 在 Dart 端需替代方案 | `charset` 包或自实现简化版检测 |
| iOS/Android 文件权限 | 沙盒限制 | 使用应用文档目录 + SAF（Android） |
| 跨平台 UI 差异 | 桌面菜单栏 vs 移动端抽屉 | 响应式布局 + 平台判断 |

---

## 九、工期估算

| 阶段 | 工期 | 累计 |
|------|------|------|
| Phase 0: 项目初始化 | 1-2 天 | 2 天 |
| Phase 1: 核心逻辑层 | 2-3 天 | 5 天 |
| Phase 2: 数据层 | 1-2 天 | 7 天 |
| Phase 3: 编辑器 UI | 3-4 天 | 11 天 |
| Phase 4: 功能模块 | 3-4 天 | 15 天 |
| Phase 5: 响应式与优化 | 2-3 天 | 18 天 |
| Phase 6: 测试与发布 | 2-3 天 | 21 天 |

**总计：约 15-21 个工作日**（单人开发）

> 建议采用 MVP 策略：先完成 Phase 0-3（基础编辑器）发布 v0.1，再逐步迭代功能。
