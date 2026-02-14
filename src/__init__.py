"""changeTXT - 基于 PyQt5 的文本编辑与处理工具
"""
__version__ = "0.2.0"

from src.core import FileHandler, TextProcessor
from src.ui import TextEditor

__all__ = [
    "FileHandler",
    "TextProcessor",
    "TextEditor",
]
