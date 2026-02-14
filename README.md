# changeTXT

基于 PyQt5 的文本编辑与处理工具，采用分层架构设计。

## 功能特性

- **文件操作**：打开和保存文本文件，支持自动检测文件编码
- **文本整理**：一键清理文本中的多余空格、空行，自动格式化章节标题
- **查找功能**：支持向前/向后查找文本内容，高亮显示匹配项
- **替换功能**：
  - 全部替换
  - 仅替换双引号外的内容（保留引用内容不变）
- **字体缩放**：支持 Ctrl + 鼠标滚轮调整字体大小

## 项目架构

本项目采用分层架构设计，实现关注点分离：

```
changeTXT/
├── src/
│   ├── core/                   # 核心业务逻辑
│   │   ├── text_processor.py   # 文本处理
│   │   └── file_handler.py      # 文件操作
│   ├── ui/                     # UI 层
│   │   ├── main_window.py      # 主窗口
│   │   ├── dialogs/            # 对话框
│   │   │   ├── find_dialog.py
│   │   │   └── replace_dialog.py
│   │   └── widgets/            # 自定义控件
│   │       └── zoom_text_edit.py
│   └── utils/                  # 工具模块
│       ├── config.py            # 配置管理
│       └── exceptions.py        # 自定义异常
├── resources/                  # 资源文件
│   └── icons/
│       └── app_icon.jpg
├── tests/                      # 测试
│   ├── test_text_processor.py
│   └── test_file_handler.py
├── pyproject.toml              # 项目配置
├── setup.py                    # 安装脚本
├── requirements.txt            # 依赖列表
└── main.py                     # 程序入口
```

## 安装

### 前置要求

- Python 3.7 或更高版本

### 安装依赖

```bash
pip install -r requirements.txt
```

或手动安装：

```bash
pip install PyQt5 chardet
```

### 开发环境安装

```bash
pip install -e ".[dev]"
```

## 使用方法

### 启动程序

```bash
python main.py
```

### 主要功能说明

#### 文件操作

- **打开**：通过菜单 `文件 > 打开` 选择文件
- **保存**：通过菜单 `文件 > 保存` 保存当前编辑的文本

#### 文本整理

通过菜单 `编辑 > 整理文本` 执行以下操作：
- 删除开头空格
- 删除空白段落
- 自动插入第一章标题
- 分离章节标题为独立段落
- 调整换行格式

#### 查找文本

通过菜单 `编辑 > 查找` 打开查找对话框：
- 输入查找内容
- 点击"查找上一个"或"查找下一个"进行导航
- 匹配的文本会以黄色高亮显示

#### 替换文本

通过菜单 `编辑 > 替换` 打开替换对话框：
- 输入要替换的旧文本和新文本
- 选择替换模式：
  - **全部替换**：替换所有匹配项
  - **双引号外替换**：仅替换双引号外的内容，保留引用内容

#### 字体缩放

在文本编辑器中：
- 按住 `Ctrl` 键并滚动鼠标滚轮可以放大或缩小字体

## 开发

### 运行测试

```bash
# 使用 pytest
pytest tests/

# 带覆盖率报告
pytest tests/ --cov=src --cov-report=html
```

### 代码风格

项目使用以下工具进行代码质量保证：

- **Black**：代码格式化
- **MyPy**：类型检查

```bash
# 格式化代码
black src/ tests/

# 类型检查
mypy src/
```

### 扩展功能

#### 添加新的文本处理函数

在 `src/core/text_processor.py` 中的 `TextProcessor` 类中添加新方法。

#### 添加新的 UI 组件

在 `src/ui/` 下的相应子目录中创建新组件。

#### 添加新的配置项

在 `src/utils/config.py` 中添加新的配置常量。

## 依赖项

| 包 | 版本 | 说明 |
|---|------|------|
| PyQt5 | >=5.15.0 | GUI 框架 |
| chardet | >=5.0.0 | 字符编码检测 |

开发依赖：
| 包 | 版本 | 说明 |
|---|------|------|
| pytest | >=7.0.0 | 测试框架 |
| pytest-cov | >=4.0.0 | 覆盖率报告 |
| black | >=22.0.0 | 代码格式化 |
| mypy | >=0.990 | 类型检查 |

## 注意事项

- 图标文件应放置在 `resources/icons/` 目录下
- 默认字体为 Arial 12pt
- 文件保存默认使用 UTF-8 编码
- 所有核心功能都有完善的错误处理和用户提示

## 版本历史

- **v0.2.0**：架构重构，分层设计，添加类型注解和测试
- **v0.1.0**：初始版本

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
