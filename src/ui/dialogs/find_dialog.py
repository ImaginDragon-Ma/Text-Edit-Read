"""查找对话框

提供文本查找功能的对话框。
"""
from typing import Optional, Tuple

from PyQt5.QtCore import Qt
from PyQt5.QtGui import QColor, QTextCharFormat, QFont
from PyQt5.QtWidgets import (
    QDialog,
    QVBoxLayout,
    QLineEdit,
    QPushButton,
    QLabel,
)

from src.utils.config import HIGHLIGHT_COLOR
from src.core.text_processor import TextProcessor


class FindDialog(QDialog):
    """查找对话框"""

    def __init__(self, parent):
        """初始化查找对话框

        Args:
            parent: 父窗口（TextEditor 实例）
        """
        super().__init__(parent)
        self._parent = parent
        self._init_ui()

    def _init_ui(self) -> None:
        """初始化UI界面"""
        self.setWindowTitle('查找')
        self.resize(400, 150)

        # 标题和说明
        title_label = QLabel("查找文本")
        title_font = QFont()
        title_font.setPointSize(10)
        title_font.setBold(True)
        title_label.setFont(title_font)

        # 查找输入框
        self._search_input = QLineEdit(self)
        self._search_input.setPlaceholderText("请输入查找内容")
        self._search_input.setMinimumHeight(30)

        # 按钮布局
        button_layout = QVBoxLayout()
        self._search_button_prev = QPushButton('查找上一个', self)
        self._search_button_next = QPushButton('查找下一个', self)

        self._search_button_prev.clicked.connect(self._find_previous)
        self._search_button_next.clicked.connect(self._find_next)

        button_layout.addWidget(self._search_button_prev)
        button_layout.addWidget(self._search_button_next)

        # 主布局
        layout = QVBoxLayout()
        layout.addWidget(title_label)
        layout.addWidget(self._search_input)
        layout.addLayout(button_layout)

        self.setLayout(layout)

        # 聚焦到输入框
        self._search_input.setFocus()

    def _find_previous(self) -> None:
        """查找上一个匹配项"""
        search_term = self._search_input.text()
        current_text = self._parent.text_edit.toPlainText()
        cursor_pos = self._parent.text_edit.textCursor().position()

        pos, word = TextProcessor.find_text(
            current_text,
            search_term,
            start_pos=cursor_pos,
            direction='previous'
        )

        if pos is not None:
            self._highlight_text(pos, word)
        else:
            self._show_not_found_message(search_term)

    def _find_next(self) -> None:
        """查找下一个匹配项"""
        search_term = self._search_input.text()
        current_text = self._parent.text_edit.toPlainText()
        cursor_pos = self._parent.text_edit.textCursor().position()

        pos, word = TextProcessor.find_text(
            current_text,
            search_term,
            start_pos=cursor_pos,
            direction='next'
        )

        if pos is not None:
            self._highlight_text(pos, word)
        else:
            self._show_not_found_message(search_term)

    def _highlight_text(self, pos: int, word: str) -> None:
        """高亮显示匹配的文本

        Args:
            pos: 匹配文本的起始位置
            word: 匹配的文本内容
        """
        cursor = self._parent.text_edit.textCursor()
        cursor.setPosition(pos)
        cursor.movePosition(cursor.NextCharacter, cursor.KeepAnchor, len(word))

        # 设置高亮格式
        highlight_format = QTextCharFormat()
        highlight_format.setBackground(QColor(HIGHLIGHT_COLOR))
        cursor.setCharFormat(highlight_format)

        # 应用新的光标
        self._parent.text_edit.setTextCursor(cursor)
        self._parent.text_edit.setFocus()

    def _show_not_found_message(self, search_term: str) -> None:
        """显示未找到消息

        Args:
            search_term: 搜索的文本
        """
        self._parent.text_edit.setFocus()
        # 可以添加状态栏提示或其他反馈方式
