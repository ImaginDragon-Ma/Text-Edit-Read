"""替换对话框

提供文本替换功能的对话框。
"""
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import (
    QDialog,
    QVBoxLayout,
    QLineEdit,
    QPushButton,
    QComboBox,
    QLabel,
)

from src.core.text_processor import TextProcessor


class ReplaceDialog(QDialog):
    """替换对话框"""

    def __init__(self, parent):
        """初始化替换对话框

        Args:
            parent: 父窗口（TextEditor 实例）
        """
        super().__init__(parent)
        self._parent = parent
        self._init_ui()

    def _init_ui(self) -> None:
        """初始化UI界面"""
        self.setWindowTitle('替换')
        self.resize(400, 200)

        # 标题
        title_label = QLabel("替换文本")
        title_font = QFont()
        title_font.setPointSize(10)
        title_font.setBold(True)
        title_label.setFont(title_font)

        # 旧文本输入框
        old_text_label = QLabel("查找内容:")
        self._old_text_input = QLineEdit(self)
        self._old_text_input.setPlaceholderText("要替换的文本")
        self._old_text_input.setMinimumHeight(30)

        # 新文本输入框
        new_text_label = QLabel("替换为:")
        self._new_text_input = QLineEdit(self)
        self._new_text_input.setPlaceholderText("新文本")
        self._new_text_input.setMinimumHeight(30)

        # 替换模式选择
        mode_label = QLabel("替换模式:")
        self._replace_mode_combo = QComboBox(self)
        self._replace_mode_combo.addItem("全部替换")
        self._replace_mode_combo.addItem("双引号外替换")

        # 替换按钮
        self._replace_button = QPushButton('开始替换', self)
        self._replace_button.setMinimumHeight(35)
        self._replace_button.clicked.connect(self._replace_text)

        # 主布局
        layout = QVBoxLayout()
        layout.addWidget(title_label)
        layout.addWidget(old_text_label)
        layout.addWidget(self._old_text_input)
        layout.addWidget(new_text_label)
        layout.addWidget(self._new_text_input)
        layout.addWidget(mode_label)
        layout.addWidget(self._replace_mode_combo)
        layout.addWidget(self._replace_button)

        self.setLayout(layout)

        # 聚焦到输入框
        self._old_text_input.setFocus()

    def _replace_text(self) -> None:
        """执行替换操作"""
        old_text = self._old_text_input.text()
        new_text = self._new_text_input.text()

        if not old_text:
            # 如果没有输入查找内容，直接返回
            return

        replace_all = self._replace_mode_combo.currentText() == "全部替换"
        current_text = self._parent.text_edit.toPlainText()
        lines = current_text.splitlines()

        try:
            if replace_all:
                # 全部替换
                new_text_content = TextProcessor.replace_all_word(
                    lines,
                    old_text,
                    new_text
                )
            else:
                # 双引号外替换
                new_text_content = TextProcessor.replace_except_in_quotes(
                    lines,
                    old_text,
                    new_text
                )

            # 设置新文本（不使用 setText，避免覆盖撤销堆栈）
            self._parent.text_edit.setText("\n".join(new_text_content))
            self._parent.text_edit.setFocus()
        except Exception as e:
            # 替换失败时的处理
            from PyQt5.QtWidgets import QMessageBox
            QMessageBox.warning(
                self,
                '替换失败',
                f'替换操作失败：{e}'
            )
