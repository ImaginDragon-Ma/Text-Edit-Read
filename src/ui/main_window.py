"""主窗口模块

定义应用程序的主窗口和核心 UI 组件。
"""
from pathlib import Path
from typing import Optional

from PyQt5.QtWidgets import (
    QMainWindow,
    QAction,
    QFileDialog,
    QMessageBox,
    QShortcut,
)
from PyQt5.QtGui import QFont, QIcon, QKeySequence
from PyQt5.QtCore import Qt

from src.utils.config import (
    APP_ICON_NAME,
    APP_NAME,
    DEFAULT_FONT_FAMILY,
    DEFAULT_FONT_SIZE,
    HIGHLIGHT_COLOR,
    ICONS_DIR,
    WINDOW_HEIGHT,
    WINDOW_WIDTH,
    WINDOW_X,
    WINDOW_Y,
)
from src.utils.exceptions import FileOperationError
from src.core.text_processor import TextProcessor
from src.ui.dialogs import FindDialog, ReplaceDialog
from src.ui.widgets import ZoomTextEdit


class TextEditor(QMainWindow):
    """文本编辑器主窗口

    提供完整的文本编辑功能，包括文件操作、文本处理、查找和替换等。
    """

    def __init__(self):
        """初始化主窗口"""
        super().__init__()

        self._text_content: str = ""
        self._current_file: Optional[Path] = None
        self._saved_content: Optional[str] = None  # 保存的内容快照，用于恢复

        self._init_ui()
        self._init_connections()

    def _init_ui(self) -> None:
        """初始化UI界面"""
        # 设置窗口标题和图标
        self.setWindowTitle(APP_NAME)
        self._set_window_icon()
        self.setGeometry(WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT)

        # 设置文本编辑区域
        self.text_edit = ZoomTextEdit(self)
        self.setCentralWidget(self.text_edit)

        # 设置默认字体
        default_font = QFont(DEFAULT_FONT_FAMILY, DEFAULT_FONT_SIZE)
        self.text_edit.setFont(default_font)

        # 创建菜单栏
        self._create_menu_bar()

    def _set_window_icon(self) -> None:
        """设置窗口图标"""
        icon_path = ICONS_DIR / APP_ICON_NAME
        if icon_path.exists():
            self.setWindowIcon(QIcon(str(icon_path)))
        else:
            # 图标不存在时忽略，不影响程序运行
            pass

    def _create_menu_bar(self) -> None:
        """创建菜单栏"""
        menubar = self.menuBar()

        # 文件菜单
        file_menu = menubar.addMenu('文件')
        open_action = QAction('打开', self)
        save_action = QAction('保存', self)

        # 设置快捷键
        save_action.setShortcut('Ctrl+S')

        open_action.triggered.connect(self._open_file)
        save_action.triggered.connect(self._save_file)

        file_menu.addAction(open_action)
        file_menu.addAction(save_action)

        # 编辑菜单
        edit_menu = menubar.addMenu('编辑')
        undo_action = QAction('撤销', self)
        redo_action = QAction('恢复保存', self)  # 重做改为恢复保存
        clean_action = QAction('整理文本', self)
        find_action = QAction('查找', self)
        replace_action = QAction('替换', self)

        # 设置快捷键
        undo_action.setShortcut('Ctrl+Z')
        redo_action.setShortcut('Ctrl+Y')

        undo_action.triggered.connect(self._undo)
        redo_action.triggered.connect(self._redo)
        clean_action.triggered.connect(self._clean_text)
        find_action.triggered.connect(self._find_text)
        replace_action.triggered.connect(self._replace_text)

        edit_menu.addAction(undo_action)
        edit_menu.addAction(redo_action)
        edit_menu.addSeparator()
        edit_menu.addAction(clean_action)
        edit_menu.addAction(find_action)
        edit_menu.addAction(replace_action)

    def _init_connections(self) -> None:
        """初始化信号连接和快捷键"""
        # 快捷键已在菜单项中设置，无需重复绑定
        pass

    def _undo(self) -> None:
        """撤销操作"""
        self.text_edit.undo()

    def _redo(self) -> None:
        """恢复到上一次保存的内容

        Ctrl+Y 功能：恢复到上一次保存的状态，而非文本编辑的重做。
        """
        if self._saved_content is None:
            QMessageBox.information(
                self,
                '提示',
                '没有可恢复的保存记录'
            )
            return

        # 询问用户是否确认恢复
        reply = QMessageBox.question(
            self,
            '恢复确认',
            '是否恢复到上一次保存的内容？\n\n注意：这将覆盖当前编辑的内容。',
            QMessageBox.Yes | QMessageBox.No
        )

        if reply == QMessageBox.Yes:
            # 使用 QTextCursor 替换文本，保留撤销功能
            cursor = self.text_edit.textCursor()
            cursor.select(cursor.Document)  # 选择全部内容
            cursor.insertText(self._saved_content)  # 插入保存的内容（可撤销）
            QMessageBox.information(
                self,
                '恢复成功',
                '已恢复到上一次保存的内容'
            )

    def _open_file(self) -> None:
        """打开文件"""
        file_path, _ = QFileDialog.getOpenFileName(self, '打开文件')
        if file_path:
            try:
                from src.core.file_handler import FileHandler

                path = Path(file_path)
                content = FileHandler.read_file(path)

                self._text_content = content
                self._current_file = path
                self.text_edit.setText(content)
                self.setWindowTitle(f'{APP_NAME} - {path.name}')
            except FileOperationError as e:
                QMessageBox.critical(
                    self,
                    '文件错误',
                    str(e)
                )
            except Exception as e:
                QMessageBox.critical(
                    self,
                    '错误',
                    f'打开文件时发生未知错误：{e}'
                )

    def _save_file(self) -> None:
        """保存文件"""
        file_path, _ = QFileDialog.getSaveFileName(self, '保存文件')
        if file_path:
            try:
                from src.core.file_handler import FileHandler

                path = Path(file_path)
                content = self.text_edit.toPlainText()

                FileHandler.save_file(path, content)

                # 保存当前内容快照（用于"重做"恢复功能）
                self._saved_content = content

                self._current_file = path
                self.setWindowTitle(f'{APP_NAME} - {path.name}')
                QMessageBox.information(
                    self,
                    '保存成功',
                    f'文件已保存到：{path.name}'
                )
            except FileOperationError as e:
                QMessageBox.critical(
                    self,
                    '保存失败',
                    str(e)
                )
            except Exception as e:
                QMessageBox.critical(
                    self,
                    '错误',
                    f'保存文件时发生未知错误：{e}'
                )

    def _clean_text(self) -> None:
        """整理文本（支持撤销）"""
        self._text_content = self.text_edit.toPlainText()
        try:
            self._text_content = TextProcessor.clean_text(self._text_content)
            # 使用 QTextCursor 替换文本，保留撤销功能
            cursor = self.text_edit.textCursor()
            cursor.select(cursor.Document)  # 选择全部内容
            cursor.insertText(self._text_content)  # 插入新文本（可撤销）
        except Exception as e:
            QMessageBox.warning(
                self,
                '处理失败',
                f'文本整理失败：{e}'
            )

    def _find_text(self) -> None:
        """打开查找对话框"""
        find_dialog = FindDialog(self)
        find_dialog.show()

    def _replace_text(self) -> None:
        """打开替换对话框"""
        replace_dialog = ReplaceDialog(self)
        replace_dialog.textReplaced.connect(self._on_text_replaced)  # 连接替换完成信号
        replace_dialog.show()

    def _on_text_replaced(self, new_text: str) -> None:
        """文本替换完成回调（支持撤销）"""
        # 使用 QTextCursor 替换文本，保留撤销功能
        cursor = self.text_edit.textCursor()
        cursor.select(cursor.Document)  # 选择全部内容
        cursor.insertText(new_text)  # 插入新文本（可撤销）

    @property
    def text_content(self) -> str:
        """获取文本内容"""
        return self._text_content

    @text_content.setter
    def text_content(self, value: str) -> None:
        """设置文本内容"""
        self._text_content = value
        self.text_edit.setText(value)
