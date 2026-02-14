"""可缩放文本编辑控件

支持使用 Ctrl + 鼠标滚轮缩放字体的文本编辑控件。
"""
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QTextEdit

from src.utils.config import (
    DEFAULT_FONT_FAMILY,
    DEFAULT_FONT_SIZE,
    FONT_STEP,
    MAX_FONT_SIZE,
    MIN_FONT_SIZE,
)


class ZoomTextEdit(QTextEdit):
    """支持字体缩放的文本编辑控件

    通过 Ctrl + 鼠标滚轮来放大或缩小字体。
    """

    def __init__(self, parent=None):
        """初始化控件

        Args:
            parent: 父控件
        """
        super().__init__(parent)
        self._font_size = DEFAULT_FONT_SIZE
        self._update_font()

    def wheelEvent(self, event) -> None:
        """处理鼠标滚轮事件

        当按住 Ctrl 键时，滚轮上下滚动会缩放字体。

        Args:
            event: 鼠标滚轮事件
        """
        if event.modifiers() == Qt.ControlModifier:
            delta = event.angleDelta().y()
            if delta > 0:
                self._font_size = min(self._font_size + FONT_STEP, MAX_FONT_SIZE)
            elif delta < 0:
                self._font_size = max(self._font_size - FONT_STEP, MIN_FONT_SIZE)

            self._update_font()
            event.accept()
        else:
            super().wheelEvent(event)

    def _update_font(self) -> None:
        """更新字体设置"""
        font = self.font()
        font.setFamily(DEFAULT_FONT_FAMILY)
        font.setPointSize(self._font_size)
        self.setFont(font)

    @property
    def font_size(self) -> int:
        """获取当前字体大小"""
        return self._font_size

    @font_size.setter
    def font_size(self, size: int) -> None:
        """设置字体大小

        Args:
            size: 字体大小（会自动限制在最小值和最大值之间）
        """
        self._font_size = max(MIN_FONT_SIZE, min(size, MAX_FONT_SIZE))
        self._update_font()
