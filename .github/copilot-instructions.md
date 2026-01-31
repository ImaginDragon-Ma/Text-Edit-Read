# Copilot Instructions for AI Agents

## 项目概览
本项目为基于 PyQt5 的文本编辑与处理工具，主要包含以下核心组件：
- `main.py`：主程序，提供图形界面（QMainWindow），集成文本编辑、文件操作、文本清理、查找与替换等功能。
- `functions.py`：文本处理函数库，包含清理文本、查找、替换等核心算法。
- `test.py`：演示或测试用例，包含自定义的文本缩放编辑器（TextZoomEdit），用于实验性功能。

## 主要架构与数据流
- UI 逻辑与文本处理解耦：界面事件（如菜单点击）通过信号与槽机制调用 `functions.py` 中的纯函数。
- 文本内容通过 `QTextEdit` 控件展示和编辑，所有处理均在内存中完成。
- 文件操作（打开/保存）通过标准对话框实现，支持自动检测文件编码（chardet）。

## 关键开发流程
- 运行主程序：
  ```bash
  python main.py
  ```
- 依赖安装：
  ```bash
  pip install PyQt5 chardet
  ```
- 测试/实验功能可直接运行 `test.py`。

## 项目约定与模式
- 文本处理函数均为纯函数，参数与返回值均为字符串，便于单元测试与复用。
- UI 事件绑定采用 PyQt5 的标准信号/槽机制。
- 主要界面元素（如菜单、编辑区）在 `TextEditor` 类的 `init_ui` 方法中集中初始化。
- 图标、字体等资源需放置于项目根目录（如 `icon.jpg`）。

## 重要文件说明
- `main.py`：入口，定义 `TextEditor` 主窗口，集成所有功能。
- `functions.py`：实现如 `clean_text`、`find_text`、`replace_all_word`、`replace_except_in_quotes` 等文本处理逻辑。
- `test.py`：包含 `TextZoomEdit`，用于测试 Ctrl+滚轮缩放字体等功能。

## 其他说明
- 项目无特殊构建脚本，直接运行 Python 文件即可。
- 若需扩展功能，建议新增处理函数至 `functions.py`，并在 `main.py` 中通过菜单或按钮集成。
- 代码注释多为中文，便于理解处理逻辑。

---
如需进一步了解某功能或有不明确之处，请查阅对应文件或补充说明。