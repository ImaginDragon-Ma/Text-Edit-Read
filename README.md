# Text-Edit-Read

基于 Flutter + FastAPI 的跨平台文本编辑与阅读工具，采用分层架构设计，一套代码覆盖 **Android、iOS、Web、Windows、macOS、Linux** 六大平台。

## ✨ 功能特性

### 📝 文本编辑（核心创新）
- **智能文本整理**：一键清理多余空格、空行，自动格式化章节标题
- **高级替换**：全部替换 + 双引号外替换（保留引用内容不变）
- **查找导航**：支持向前/向后查找，黄色高亮显示匹配项
- **章节检测**：自动识别「序章」「第X章」，生成可点击目录

### 📖 阅读模式
- 专注阅读体验，1.8 行高中文排版优化
- 章节目录侧边栏，点击跳转
- 底部进度条，页码/章节信息

### 🎨 界面特色
- **暖色调主题**：琥珀色主色调，深色侧边栏
- **亮色/暗色主题切换**
- **响应式布局**：自动适配手机、平板、桌面
- **流畅动画**：面板展开/折叠弹性动画

### 📂 文件管理
- 文件库视图（类似书城），支持网格/列表切换
- 收藏、搜索、最近打开
- 支持 UTF-8 / GBK 等多种编码自动检测

---

## 🚀 快速开始

### 方式一：网页版（无需安装，推荐体验）

#### 方法 A：在线预览（推荐）

1. 访问在线演示地址（如已部署）
2. 打开即用，无需下载

#### 方法 B：本地启动 Web 版

**前置要求：**
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x
- Dart 3.x

**步骤：**

```bash
# 1. 克隆项目
git clone https://github.com/ImaginDragon-Ma/Text-Edit-Read.git
cd Text-Edit-Read

# 2. 进入前端目录
cd frontend

# 3. 获取依赖（国内用户推荐使用镜像）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get

# 4. 启动 Web 开发服务器
flutter run -d chrome

# 或构建发布版本
flutter build web --release
# 构建产物在 build/web/ 目录，可用任意 HTTP 服务器托管
```

#### 方法 C：部署到静态网站托管

```bash
# 构建后直接上传 build/web/ 目录到：
# - GitHub Pages
# - Vercel
# - Netlify
# - Cloudflare Pages
# - 任何支持静态网站的托管服务
```

---

### 方式二：桌面客户端（Windows / macOS / Linux）

#### 前置要求

| 平台 | 要求 |
|------|------|
| **Windows** | Windows 10+，已安装 [Flutter SDK](https://flutter.dev/docs/get-started/install/windows) |
| **macOS** | macOS 10.15+，已安装 [Flutter SDK](https://flutter.dev/docs/get-started/install/macos) + Xcode |
| **Linux** | 已安装 [Flutter SDK](https://flutter.dev/docs/get-started/install/linux) + `clang cmake ninja-build pkg-config libgtk-3-dev` |

#### 步骤

```bash
# 1. 克隆项目
git clone https://github.com/ImaginDragon-Ma/Text-Edit-Read.git
cd Text-Edit-Read/frontend

# 2. 获取依赖（国内镜像）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get

# 3. 构建桌面应用
# Windows:
flutter build windows --release
# 产物在 build/windows/x64/runner/Release/

# macOS:
flutter build macos --release
# 产物在 build/macos/Build/Products/Release/

# Linux:
flutter build linux --release
# 产物在 build/linux/x64/release/bundle/
```

#### 运行（开发模式）

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

---

### 方式三：手机 App（Android / iOS）

#### 前置要求

| 平台 | 要求 |
|------|------|
| **Android** | Android Studio + Android SDK（API 21+） |
| **iOS** | macOS + Xcode 15+（需 Apple 开发者账号签名） |

#### 步骤

```bash
# 1. 克隆项目
git clone https://github.com/ImaginDragon-Ma/Text-Edit-Read.git
cd Text-Edit-Read/frontend

# 2. 获取依赖（国内镜像）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get

# 3. 构建 Android APK
flutter build apk --release
# 产物在 build/app/outputs/flutter-apk/app-release.apk

# 或构建 App Bundle（推荐上传 Google Play）
flutter build appbundle --release

# 4. 构建 iOS（仅限 macOS）
flutter build ios --release
# 然后在 Xcode 中签名并上传 App Store
```

#### 运行（开发模式）

```bash
# 确保设备已连接或模拟器已启动
flutter devices

# Android
flutter run -d <device-id>

# iOS
flutter run -d <device-id>
```

---

## 🏗️ 项目架构

```
Text-Edit-Read/
├── frontend/                    # Flutter 前端（跨平台）
│   ├── lib/
│   │   ├── core/               # 领域层（纯 Dart，无 UI 依赖）
│   │   │   ├── text_processor.dart
│   │   │   ├── file_handler.dart
│   │   │   ├── chapter_detector.dart
│   │   │   └── models/
│   │   ├── data/               # 数据层
│   │   │   ├── services/       # 文件服务、API 客户端
│   │   │   ├── storage/        # Hive 本地存储、SQLite
│   │   │   └── repositories/   # 文件仓库、设置仓库
│   │   ├── features/           # 功能模块（Feature-first）
│   │   │   ├── library/        # 文件库首页
│   │   │   ├── editor/         # 编辑模式
│   │   │   ├── reader/         # 阅读模式
│   │   │   ├── find_replace/   # 查找替换
│   │   │   ├── chapter_nav/    # 章节导航
│   │   │   ├── text_processing/# 文本整理
│   │   │   ├── file_manager/   # 文件管理
│   │   │   └── settings/       # 设置
│   │   ├── shared/             # 共享组件与主题
│   │   └── main.dart           # 入口
│   ├── test/                   # 测试
│   └── pubspec.yaml
│
├── backend/                     # FastAPI 后端（可选）
│   ├── app/
│   │   ├── main.py             # API 入口
│   │   ├── routers/            # 路由（文本处理、文件操作）
│   │   ├── services/           # 业务逻辑（迁移自原 Python 版本）
│   │   └── models/             # Pydantic 模型
│   └── tests/
│
├── src/                         # 原始 PyQt5 版本（保留）
│   ├── core/                    # Python 核心逻辑
│   ├── ui/                      # PyQt5 界面
│   └── utils/
│
├── docs/                        # 文档
│   ├── requirements-analysis.md # 需求分析报告
│   └── git-operations.md        # Git 操作记录
│
└── README.md
```

## 🧪 运行测试

### 前端测试

```bash
cd frontend

# 单元测试
flutter test

# 指定测试文件
flutter test test/core/text_processor_test.dart

# 带覆盖率
flutter test --coverage
```

### 后端测试

```bash
cd backend

# 安装依赖
pip install -r requirements.txt

# 运行测试
pip install pytest httpx
pytest tests/
```

## 🔧 技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| 前端框架 | Flutter 3.x | 六端统一 |
| 状态管理 | flutter_bloc | 事件驱动 |
| 本地存储 | Hive + SharedPreferences | 配置和缓存 |
| HTTP 客户端 | Dio | API 调用 |
| 后端 | FastAPI | 可选的高级功能 |
| 原始版本 | PyQt5 | 桌面端（保留） |

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feat/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feat/amazing-feature`)
5. 创建 Pull Request

## 📄 许可证

MIT License

## 🙏 致谢

- [Flutter](https://flutter.dev) — 跨平台 UI 框架
- [FastAPI](https://fastapi.tiangolo.com) — Python Web 框架
- [Koodo Reader](https://www.koodoreader.com) — UI 设计参考
