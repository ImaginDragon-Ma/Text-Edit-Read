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
    QSplitter,
    QWidget,
    QStatusBar,
    QLabel,
    QTabBar,
)
from PyQt5.QtGui import QFont, QIcon, QKeySequence
from PyQt5.QtCore import Qt, QTimer

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

        # 多文件支持
        self._open_files: List[dict] = []  # 存储打开的文件信息 {path, content}
        self._current_file_index: int = -1  # 当前激活的文件索引

        # 章节位置列表 [(position, title), ...]
        self._chapter_positions: List[Tuple[int, str]] = []
        self._current_chapter_index: int = 0  # 当前章节索引

        # 兼容旧代码
        self._text_content: str = ""
        self._current_file: Optional[Path] = None

        # 创建提示信息清除计时器
        self._message_timer = QTimer(self)
        self._message_timer.timeout.connect(self._clear_message)

        self._init_ui()
        self._init_connections()

    def _init_ui(self) -> None:
        """初始化UI界面"""
        # 设置窗口标题和图标
        self.setWindowTitle(APP_NAME)
        self._set_window_icon()
        self.setGeometry(WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT)

        # 创建顶部标签栏（用于显示多个打开的文件）
        self.file_tab_bar = QTabBar(self)
        self.file_tab_bar.setExpanding(False)
        self.file_tab_bar.setDocumentMode(True)
        self.file_tab_bar.setMovable(True)
        self.file_tab_bar.setTabsClosable(True)
        self.file_tab_bar.tabCloseRequested.connect(self._on_tab_close_requested)
        self.file_tab_bar.currentChanged.connect(self._on_tab_changed)
        self.file_tab_bar.show()

        # 创建主分割器（水平分割，左侧目录，右侧文本）
        self.splitter = QSplitter(Qt.Horizontal, self)

        # 创建左侧目录面板
        self.toc_widget = QWidget()
        toc_layout = QVBoxLayout()
        toc_layout.setContentsMargins(0, 0, 0, 0)

        # 目录列表
        self.toc_list = QListWidget()
        # 设置为可编辑模式
        self.toc_list.setEditTriggers(QListWidget.DoubleClicked | QListWidget.EditKeyPressed)
        self.toc_list.itemDoubleClicked.connect(self._on_toc_item_clicked)
        self.toc_list.itemChanged.connect(self._on_toc_item_changed)
        toc_layout.addWidget(self.toc_list)

        self.toc_widget.setLayout(toc_layout)

        # 设置文本编辑区域
        self.text_edit = ZoomTextEdit(self)

        # 将目录和文本编辑器添加到分割器
        self.splitter.addWidget(self.toc_widget)
        self.splitter.addWidget(self.text_edit)

        # 设置分割比例（左侧200px，右侧自适应）
        self.splitter.setStretchFactor(0, 0)
        self.splitter.setStretchFactor(1, 1)
        self.splitter.setSizes([200, 800])

        # 创建主容器（垂直布局：标签栏 + 分割器）
        main_widget = QWidget()
        main_layout = QVBoxLayout()
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)
        main_layout.addWidget(self.file_tab_bar)
        main_layout.addWidget(self.splitter)
        main_widget.setLayout(main_layout)

        # 将主容器设为中心控件
        self.setCentralWidget(main_widget)

        # 设置默认字体
        default_font = QFont(DEFAULT_FONT_FAMILY, DEFAULT_FONT_SIZE)
        self.text_edit.setFont(default_font)

        # 连接文本变化信号
        self.text_edit.textChanged.connect(self._on_text_changed)
        self.text_edit.cursorPositionChanged.connect(self._on_cursor_position_changed)
        self.text_edit.selectionChanged.connect(self._on_selection_changed)

        # 创建状态栏
        self._create_status_bar()

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
        save_as_action = QAction('另存为', self)

        # 设置快捷键
        save_action.setShortcut('Ctrl+S')
        save_as_action.setShortcut('Ctrl+Shift+S')

        open_action.triggered.connect(self._open_file)
        save_action.triggered.connect(self._save_file)
        save_as_action.triggered.connect(self._save_file_as)

        file_menu.addAction(open_action)
        file_menu.addAction(save_action)
        file_menu.addAction(save_as_action)

        # 编辑菜单
        edit_menu = menubar.addMenu('编辑')
        undo_action = QAction('撤销', self)
        clean_action = QAction('整理文本', self)
        find_action = QAction('查找', self)
        replace_action = QAction('替换', self)

        # 设置快捷键
        undo_action.setShortcut('Ctrl+Z')

        undo_action.triggered.connect(self._undo)
        clean_action.triggered.connect(self._clean_text)
        find_action.triggered.connect(self._find_text)
        replace_action.triggered.connect(self._replace_text)

        edit_menu.addAction(undo_action)
        edit_menu.addSeparator()
        edit_menu.addAction(clean_action)
        edit_menu.addAction(find_action)
        edit_menu.addAction(replace_action)

        # 视图菜单
        view_menu = menubar.addMenu('视图')
        toc_action = QAction('目录', self)

        toc_action.triggered.connect(self._show_toc)

        view_menu.addAction(toc_action)

    def _init_connections(self) -> None:
        """初始化信号连接和快捷键"""
        # 快捷键已在菜单项中设置，无需重复绑定
        pass

    def _create_status_bar(self) -> None:
        """创建状态栏"""
        self.status_bar = QStatusBar(self)
        self.setStatusBar(self.status_bar)

        # 章节信息标签
        self.chapter_label = QLabel('章节: 0/0', self)
        self.status_bar.addWidget(self.chapter_label)

        # 添加分隔符
        self.status_bar.addPermanentWidget(QLabel('|', self))

        # 提示信息标签
        self.message_label = QLabel('', self)
        self.message_label.setStyleSheet("color: green;")
        self.status_bar.addPermanentWidget(self.message_label)

        # 添加分隔符
        self.status_bar.addPermanentWidget(QLabel('|', self))

        # 选中文字数信息标签
        self.selection_count_label = QLabel('选中: 0字', self)
        self.status_bar.addPermanentWidget(self.selection_count_label)

        # 添加分隔符
        self.status_bar.addPermanentWidget(QLabel('|', self))

        # 字数信息标签
        self.word_count_label = QLabel('字数: 0/0', self)
        self.status_bar.addPermanentWidget(self.word_count_label)

        # 初始化状态
        self._update_status_bar()

    def _on_cursor_position_changed(self) -> None:
        """光标位置变化时更新当前章节"""
        if not self._chapter_positions:
            return

        cursor_position = self.text_edit.textCursor().position()
        current_index = 0

        # 找到当前光标所在章节
        for i, (position, _) in enumerate(self._chapter_positions):
            if position <= cursor_position:
                current_index = i
            else:
                break

        self._current_chapter_index = current_index
        self._update_status_bar()

    def _update_status_bar(self) -> None:
        """更新状态栏信息"""
        # 更新章节信息
        total_chapters = len(self._chapter_positions)
        current_chapter = self._current_chapter_index + 1 if total_chapters > 0 else 0
        self.chapter_label.setText(f'章节: {current_chapter}/{total_chapters}')

        # 更新字数信息
        text = self.text_edit.toPlainText()
        total_words = len(text)

        # 计算当前章节字数
        if total_chapters > 0 and self._current_chapter_index < total_chapters:
            start_pos = self._chapter_positions[self._current_chapter_index][0]
            # 计算当前章节的结束位置（下一章开始位置或文本结尾）
            if self._current_chapter_index < total_chapters - 1:
                end_pos = self._chapter_positions[self._current_chapter_index + 1][0]
            else:
                end_pos = len(text)
            chapter_words = len(text[start_pos:end_pos])
        else:
            chapter_words = 0

        self.word_count_label.setText(f'字数: {chapter_words}/{total_words}')

    def _show_message(self, message: str) -> None:
        """在状态栏显示提示信息（3秒后消失）"""
        self.message_label.setText(message)
        # 停止之前的计时器（如果有）
        self._message_timer.stop()
        # 3秒后清除提示
        self._message_timer.start(3000)

    def _clear_message(self) -> None:
        """清除状态栏提示信息"""
        self.message_label.setText('')
        self._message_timer.stop()

    def _on_text_changed(self) -> None:
        """文本变化时更新章节位置"""
        # 延迟更新，避免频繁扫描
        self._update_chapter_positions()
        self._update_toc_list()
        self._update_status_bar()

    def _undo(self) -> None:
        """撤销操作"""
        if self.text_edit.document().isUndoAvailable():
            self.text_edit.undo()
            self._show_message('撤销成功')
        else:
            self._show_message('没有可撤销的操作')

    def _on_selection_changed(self) -> None:
        """选中文本变化时更新选中文字数"""
        selected_text = self.text_edit.textCursor().selectedText()
        selected_count = len(selected_text)
        self.selection_count_label.setText(f'选中: {selected_count}字')

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

                # 检查文件是否已打开
                for i, file_info in enumerate(self._open_files):
                    if file_info['path'] == path:
                        # 文件已打开，切换到该标签
                        self.file_tab_bar.setCurrentIndex(i)
                        self._show_message(f'文件已打开：{path.name}')
                        return

                # 保存当前文件内容
                if self._current_file_index >= 0:
                    self._save_current_file_content()

                # 添加新文件到列表
                self._open_files.append({'path': path, 'content': content})

                # 添加标签
                self.file_tab_bar.addTab(path.name)

                # 切换到新标签
                new_index = len(self._open_files) - 1
                self.file_tab_bar.setCurrentIndex(new_index)

                self._show_message(f'文件已打开：{path.name}')
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

    def _save_current_file_content(self) -> None:
        """保存当前文件内容到内存"""
        if 0 <= self._current_file_index < len(self._open_files):
            self._open_files[self._current_file_index]['content'] = self.text_edit.toPlainText()

    def _on_tab_changed(self, index: int) -> None:
        """标签切换事件"""
        if index < 0:
            return

        # 保存当前文件内容
        self._save_current_file_content()

        # 切换到新文件
        self._current_file_index = index
        file_info = self._open_files[index]

        # 兼容旧代码
        self._text_content = file_info['content']
        self._current_file = file_info['path']

        # 更新文本编辑器
        self.text_edit.setPlainText(file_info['content'])
        self.setWindowTitle(f'{APP_NAME} - {file_info["path"].name}')

        # 更新章节和状态
        self._update_chapter_positions()
        self._update_toc_list()
        self._update_status_bar()

    def _on_tab_close_requested(self, index: int) -> None:
        """标签关闭请求"""
        if index < 0 or index >= len(self._open_files):
            return

        # 移除文件信息
        removed_file = self._open_files.pop(index)

        # 移除标签
        self.file_tab_bar.removeTab(index)

        # 如果关闭的是当前标签，切换到另一个标签
        if index == self._current_file_index:
            if self._open_files:
                self._current_file_index = max(0, index - 1)
                file_info = self._open_files[self._current_file_index]
                self._text_content = file_info['content']
                self._current_file = file_info['path']
                self.text_edit.setPlainText(file_info['content'])
                self.setWindowTitle(f'{APP_NAME} - {file_info["path"].name}')
                self._update_chapter_positions()
                self._update_toc_list()
                self._update_status_bar()
            else:
                # 没有文件了
                self._current_file_index = -1
                self._text_content = ""
                self._current_file = None
                self._text_edit.setPlainText("")
                self.setWindowTitle(APP_NAME)
        else:
            # 关闭的不是当前标签，调整索引
            if index < self._current_file_index:
                self._current_file_index -= 1

    def _save_file(self) -> None:
        """保存文件到原位置（Ctrl+S）"""
        # 检查是否有打开的文件，如果没有则执行另存为
        if self._current_file_index < 0:
            self._save_file_as()
            return

        try:
            from src.core.file_handler import FileHandler

            # 保存当前文件内容到内存
            self._save_current_file_content()

            # 获取当前文件信息
            file_info = self._open_files[self._current_file_index]
            content = file_info['content']
            path = file_info['path']

            FileHandler.save_file(path, content)
            self._show_message('保存成功')
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

    def _save_file_as(self) -> None:
        """另存为（Ctrl+Shift+S）"""
        file_path, _ = QFileDialog.getSaveFileName(self, '另存为')
        if file_path:
            try:
                from src.core.file_handler import FileHandler

                path = Path(file_path)
                content = self.text_edit.toPlainText()
                FileHandler.save_file(path, content)
                self._show_message(f'文件已成功保存到：{path.name}')

                # 检查文件是否已在打开列表中
                found = False
                for i, file_info in enumerate(self._open_files):
                    if file_info['path'] == path:
                        # 文件已打开，切换到该标签
                        self._open_files[i]['content'] = content
                        self.file_tab_bar.setCurrentIndex(i)
                        found = True
                        break

                if not found:
                    # 添加新文件到列表
                    self._open_files.append({'path': path, 'content': content})
                    # 添加标签
                    self.file_tab_bar.addTab(path.name)
                    # 切换到新标签
                    new_index = len(self._open_files) - 1
                    self.file_tab_bar.setCurrentIndex(new_index)

                # 更新窗口标题
                self.setWindowTitle(f'{APP_NAME} - {path.name}')

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
        """显示/隐藏侧边栏目录"""
        # 更新章节位置
        self._update_chapter_positions()
        self._update_toc_list()

        # 如果没有章节，显示提示
        if not self._chapter_positions:
            QMessageBox.information(
                self,
                '目录',
                '未找到章节标题。\n\n请在文本中添加"序章"或"第X章"格式的章节标题。'
            )

    def _update_toc_list(self) -> None:
        """更新侧边栏目录列表"""
        self.toc_list.clear()
        for position, title in self._chapter_positions:
            self.toc_list.addItem(title)

    def _on_toc_item_clicked(self, item) -> None:
        """目录项被点击时跳转到对应位置"""
        index = self.toc_list.row(item)
        self._jump_to_chapter(index)

    def _on_toc_item_changed(self, item) -> None:
        """目录项被编辑时同步到文本编辑器"""
        index = self.toc_list.row(item)
        if 0 <= index < len(self._chapter_positions):
            # 获取编辑后的标题
            new_title = item.text()
            # 获取原章节位置和标题
            position, old_title = self._chapter_positions[index]
            # 更新章节标题
            self._chapter_positions[index] = (position, new_title)
            # 同步到文本编辑器
            text = self.text_edit.toPlainText()
            # 替换文本中的章节标题
            text = text[:position] + new_title + text[position + len(old_title):]
            self.text_edit.setPlainText(text)
            self._show_message('目录已更新')

    def _jump_to_chapter(self, index: int) -> None:
        """跳转到指定章节位置（显示在文本顶部）"""
        if 0 <= index < len(self._chapter_positions):
            self._current_chapter_index = index
            position, _ = self._chapter_positions[index]
            cursor = self.text_edit.textCursor()
            cursor.setPosition(position)
            self.text_edit.setTextCursor(cursor)

            # 获取当前光标矩形位置
            cursor_rect = self.text_edit.cursorRect(cursor)
            # 计算需要滚动的距离，使章节显示在顶部
            scrollbar = self.text_edit.verticalScrollBar()
            scrollbar.setValue(scrollbar.value() + cursor_rect.top())

            self.text_edit.setFocus()

            # 更新状态栏
            self._update_status_bar()

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
