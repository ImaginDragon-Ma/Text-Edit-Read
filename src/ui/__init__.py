"""用户界面模块

提供应用程序的 UI 组件，包括主窗口、对话框和自定义控件。
"""

from .main_window import TextEditor
from .widgets import ZoomTextEdit
from .dialogs import FindDialog, ReplaceDialog

__all__ = [
    "TextEditor",
    "ZoomTextEdit",
    "FindDialog",
    "ReplaceDialog",
]
