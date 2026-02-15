"""主窗口模块

定义应用程序的主窗口和核心 UI 组件。
"""
import re
from pathlib import Path
from typing import Optional, List, Tuple

from PyQt5.QtWidgets import (
    QMainWindow,
    QAction,
    QFileDialog,
    QMessageBox,
    QShortcut,
    QListWidget,
    QDialog,
    QVBoxLayout,
    QPushButton,
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
        self._chapter_positions: List[Tuple[int, str]] = []  # 存储章节位置和名称

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

        # 连接文本变化信号
        self.text_edit.textChanged.connect(self._on_text_changed)

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
        toc_action = QAction('目录', self)
        clean_action = QAction('整理文本', self)
        find_action = QAction('查找', self)
        replace_action = QAction('替换', self)

        # 设置快捷键
        undo_action.setShortcut('Ctrl+Z')

        undo_action.triggered.connect(self._undo)
        toc_action.triggered.connect(self._show_toc)
        clean_action.triggered.connect(self._clean_text)
        find_action.triggered.connect(self._find_text)
        replace_action.triggered.connect(self._replace_text)

        edit_menu.addAction(undo_action)
        edit_menu.addAction(toc_action)
        edit_menu.addSeparator()
        edit_menu.addAction(clean_action)
        edit_menu.addAction(find_action)
        edit_menu.addAction(replace_action)

    def _init_connections(self) -> None:
        """初始化信号连接和快捷键"""
        # 快捷键已在菜单项中设置，无需重复绑定
        pass

    def _on_text_changed(self) -> None:
        """文本变化时更新章节位置"""
        # 延迟更新，避免频繁扫描
        self._update_chapter_positions()

    def _undo(self) -> None:
        """撤销操作"""
        self.text_edit.undo()

    def _jump_to_position(self, position: int) -> None:
        """跳转到指定位置"""
        cursor = self.text_edit.textCursor()
        cursor.setPosition(position)
        self.text_edit.setTextCursor(cursor)
        self.text_edit.setFocus()

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
        replace_dialog.show()

    def _show_toc(self) -> None:
        """显示目录对话框"""
        # 更新章节位置
        self._update_chapter_positions()

        if not self._chapter_positions:
            QMessageBox.information(
                self,
                '目录',
                '未找到章节标题。\n\n请在文本中添加"序章"或"第X章"格式的章节标题。'
            )
            return

        # 创建目录对话框
        dialog = QDialog(self)
        dialog.setWindowTitle('目录')
        dialog.resize(400, 500)

        # 章节列表
        chapter_list = QListWidget()

        for position, title in self._chapter_positions:
            chapter_list.addItem(title)

        # 跳转按钮
        jump_button = QPushButton('跳转', dialog)
        close_button = QPushButton('关闭', dialog)

        # 布局
        layout = QVBoxLayout()
        layout.addWidget(chapter_list)
        layout.addWidget(jump_button)
        layout.addWidget(close_button)

        dialog.setLayout(layout)

        # 连接信号
        jump_button.clicked.connect(
            lambda: self._jump_to_chapter(chapter_list.currentRow())
        )
        close_button.clicked.connect(dialog.close)

        # 双击章节项也可以跳转
        chapter_list.itemDoubleClicked.connect(
            lambda item: self._jump_to_chapter(chapter_list.row(item))
        )

        dialog.exec_()

    def _jump_to_chapter(self, index: int) -> None:
        """跳转到指定章节位置"""
        if 0 <= index < len(self._chapter_positions):
            position, _ = self._chapter_positions[index]
            cursor = self.text_edit.textCursor()
            cursor.setPosition(position)
            self.text_edit.setTextCursor(cursor)
            self.text_edit.setFocus()

    def _update_chapter_positions(self) -> None:
        """扫描文本，更新章节位置列表"""
        self._chapter_positions.clear()
        text = self.text_edit.toPlainText()

        # 匹配章节标题：序章 或 第X章
        chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)'

        for match in re.finditer(chapter_pattern, text, re.MULTILINE):
            position = match.start()
            title = match.group().strip()
            self._chapter_positions.append((position, title))

    @property
    def text_content(self) -> str:
        """获取文本内容"""
        return self._text_content

    @text_content.setter
    def text_content(self, value: str) -> None:
        """设置文本内容"""
        self._text_content = value
        self.text_edit.setText(value)
