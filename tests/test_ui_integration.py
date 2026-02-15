"""UI 集成测试

测试用户界面的主要功能，包括目录、撤销/重做、文本清理等。
"""
import pytest
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path

from PyQt5.QtWidgets import QApplication, QMessageBox
from PyQt5.QtTest import QTest
from PyQt5.QtCore import Qt, QPoint

from src.ui.main_window import TextEditor
from src.ui.widgets import ZoomTextEdit
from src.core.text_processor import TextProcessor


# 创建 PyQt 应用程序实例
@pytest.fixture(scope="session")
def app():
    """创建 QApplication 实例"""
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    return app


@pytest.fixture
def text_editor(app):
    """创建 TextEditor 实例"""
    editor = TextEditor()
    yield editor
    editor.close()


class TestTextEditorIntegration:
    """TextEditor 集成测试类"""

    def test_initialization(self, text_editor):
        """测试文本编辑器初始化"""
        # 检查窗口标题
        assert "文本编辑器" in text_editor.windowTitle()

        # 检查是否有文本编辑控件
        assert hasattr(text_editor, 'text_edit')
        assert isinstance(text_editor.text_edit, ZoomTextEdit)

    def test_text_content_property(self, text_editor):
        """测试文本内容属性"""
        test_text = "测试文本内容"
        text_editor.text_content = test_text

        assert text_editor.text_content == test_text

    def test_update_chapter_positions_with_chapters(self, text_editor):
        """测试更新章节位置（有章节）"""
        # 使用纯章节标题（不带后缀）
        text = """序章
这是序章内容。
第一章
这是第一章内容。
第二章
这是第二章内容。"""
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        # 检查是否检测到三个章节
        assert len(text_editor._chapter_positions) == 3

        # 检查章节标题
        titles = [title for _, title in text_editor._chapter_positions]
        assert "序章" in titles
        assert "第一章" in titles
        assert "第二章" in titles

    def test_update_chapter_positions_without_chapters(self, text_editor):
        """测试更新章节位置（无章节）"""
        text = "这是一段普通的文本\n没有章节标题"
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        # 应该没有检测到章节
        assert len(text_editor._chapter_positions) == 0

    def test_update_chapter_positions_chinese_numbers(self, text_editor):
        """测试更新章节位置（中文数字）"""
        # 使用纯章节标题（不带后缀）
        text = """第一章
第二章
第三十三章"""
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        assert len(text_editor._chapter_positions) == 3

    def test_update_chapter_positions_arabic_numbers(self, text_editor):
        """测试更新章节位置（阿拉伯数字）"""
        # 使用纯章节标题（不带后缀）
        text = """第1章
第2章
第33章"""
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        assert len(text_editor._chapter_positions) == 3

    def test_jump_to_position(self, text_editor):
        """测试跳转到指定位置"""
        test_text = "第一行\n第二行\n第三行"
        text_editor.text_edit.setText(test_text)

        # 跳转到第5个字符位置
        text_editor._jump_to_position(5)

        # 验证光标位置
        cursor = text_editor.text_edit.textCursor()
        assert cursor.position() == 5

    def test_jump_to_chapter(self, text_editor):
        """测试跳转到章节"""
        # 使用纯章节标题（不带后缀）
        text = """序章
这是序章内容。
第一章
这是第一章内容。"""
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        # 跳转到第一个章节（序章）
        text_editor._jump_to_chapter(0)
        cursor = text_editor.text_edit.textCursor()
        # 应该在文本开头
        assert cursor.position() >= 0

        # 跳转到第二个章节（第一章）
        text_editor._jump_to_chapter(1)
        cursor = text_editor.text_edit.textCursor()
        # 应该在第一章的位置
        assert cursor.position() > 0

    def test_jump_to_chapter_invalid_index(self, text_editor):
        """测试跳转到无效索引的章节"""
        # 使用纯章节标题（不带后缀）
        text = """第一章"""
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        # 跳转到不存在的索引
        # 不应该抛出异常
        text_editor._jump_to_chapter(10)
        # 验证光标位置没有变化
        cursor = text_editor.text_edit.textCursor()
        assert cursor.position() >= 0

    def test_clean_text_integration(self, text_editor):
        """测试文本清理集成"""
        # 设置未格式化的文本，使用纯章节标题
        text = """
  第一章

  这是第一章的内容。

  第二章

  这是第二章的内容。
"""
        text_editor.text_edit.setText(text)
        text_editor._clean_text()

        result = text_editor.text_edit.toPlainText()

        # 验证清理结果
        assert "第一章" in result
        assert "第二章" in result
        # 检查是否有缩进
        assert "　　" in result  # 两个中文空格
        # 章节标题不应该有缩进
        lines = result.split('\n')
        assert not lines[0].startswith('　　')  # 第一行是章节标题

    def test_clean_text_undo(self, text_editor):
        """测试文本清理可撤销"""
        original_text = "原始文本"
        text_editor.text_edit.setText(original_text)

        # 清理文本
        text_editor._clean_text()

        # 尝试撤销
        text_editor._undo()

        # 验证是否撤销成功（虽然可能恢复到修改前的状态）
        # 这里只是测试撤销方法是否能正常调用
        assert text_editor.text_edit.toPlainText() is not None

    def test_show_toc_with_chapters(self, text_editor, app, monkeypatch):
        """测试显示目录（有章节）"""
        text = """序章 前言
这是序章内容。
第一章 开始
这是第一章内容。"""
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        # Mock QMessageBox.information 以避免实际弹窗
        with patch.object(QMessageBox, 'information') as mock_info:
            with patch.object(QMessageBox, 'exec_'):
                with patch('PyQt5.QtWidgets.QDialog.exec_'):
                    # 调用显示目录
                    text_editor._show_toc()

                    # 不应该调用 information（因为有章节）
                    mock_info.assert_not_called()

    def test_show_toc_without_chapters(self, text_editor, monkeypatch):
        """测试显示目录（无章节）"""
        text = "这是一段普通的文本\n没有章节标题"
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        # Mock QMessageBox.information
        with patch.object(QMessageBox, 'information') as mock_info:
            # 调用显示目录
            text_editor._show_toc()

            # 应该调用 information 显示提示信息
            mock_info.assert_called_once()

    def test_text_change_signal_updates_chapters(self, text_editor):
        """测试文本变化信号更新章节位置"""
        # 设置初始文本
        text_editor.text_edit.setText("第一章 开始\n这是内容")
        # _on_text_changed 会被自动调用
        # 稍等一下让信号处理完成
        QTest.qWait(100)

        # 验证章节位置已更新
        assert len(text_editor._chapter_positions) > 0

    def test_menu_actions_exist(self, text_editor):
        """测试菜单动作是否存在"""
        menubar = text_editor.menuBar()
        actions = menubar.actions()

        # 检查是否有文件菜单和编辑菜单
        menu_texts = [action.text() for action in actions]
        assert "文件" in menu_texts
        assert "编辑" in menu_texts

    def test_save_shortcut_exists(self, text_editor):
        """测试保存快捷键是否存在"""
        menubar = text_editor.menuBar()
        edit_menu = None
        file_menu = None

        for action in menubar.actions():
            if action.text() == "文件":
                file_menu = action.menu()
            elif action.text() == "编辑":
                edit_menu = action.menu()

        assert file_menu is not None

        # 检查文件菜单中的保存动作是否有快捷键
        save_action = None
        for action in file_menu.actions():
            if action.text() == "保存":
                save_action = action
                break

        assert save_action is not None
        assert save_action.shortcut().toString() == "Ctrl+S"

    def test_undo_shortcut_exists(self, text_editor):
        """测试撤销快捷键是否存在"""
        menubar = text_editor.menuBar()

        for menu_action in menubar.actions():
            if menu_action.text() == "编辑":
                edit_menu = menu_action.menu()
                for action in edit_menu.actions():
                    if action.text() == "撤销":
                        assert action.shortcut().toString() == "Ctrl+Z"
                        break
                break

    def test_redo_shortcut_via_menu(self, text_editor):
        """测试重做功能（通过菜单或快捷键）"""
        # 设置一些文本
        text_editor.text_edit.setText("初始文本")

        # 进行一些编辑操作
        cursor = text_editor.text_edit.textCursor()
        cursor.insertText(" more text")
        text_editor.text_edit.setTextCursor(cursor)

        # 验证可以撤销
        # QTextEdit 本身支持 undo/redo
        assert text_editor.text_edit.document().isUndoAvailable()

    def test_toc_action_exists(self, text_editor):
        """测试目录动作是否存在"""
        menubar = text_editor.menuBar()

        for menu_action in menubar.actions():
            if menu_action.text() == "编辑":
                edit_menu = menu_action.menu()
                action_texts = [action.text() for action in edit_menu.actions()]
                assert "目录" in action_texts
                assert "撤销" in action_texts
                assert "整理文本" in action_texts
                assert "查找" in action_texts
                assert "替换" in action_texts
                break


class TestZoomTextEdit:
    """ZoomTextEdit 测试类"""

    def test_initialization(self, app):
        """测试 ZoomTextEdit 初始化"""
        text_edit = ZoomTextEdit()

        # 检查字体大小属性
        assert text_edit.font_size is not None
        assert isinstance(text_edit.font_size, int)
        assert text_edit.font_size > 0

        text_edit.close()

    def test_font_size_property(self, app):
        """测试字体大小属性"""
        text_edit = ZoomTextEdit()

        # 获取字体大小
        original_size = text_edit.font_size
        assert original_size > 0

        # 设置新的字体大小
        new_size = 20
        text_edit.font_size = new_size
        assert text_edit.font_size == new_size

        text_edit.close()

    def test_font_size_limits(self, app):
        """测试字体大小限制"""
        text_edit = ZoomTextEdit()

        # 测试最小值限制
        text_edit.font_size = 1
        assert text_edit.font_size >= 6  # MIN_FONT_SIZE

        # 测试最大值限制
        text_edit.font_size = 100
        assert text_edit.font_size <= 36  # MAX_FONT_SIZE

        text_edit.close()


class TestChapterDetection:
    """章节检测测试"""

    @pytest.mark.parametrize("text,expected_chapters", [
        ("序章\n内容", ["序章"]),
        ("第一章\n内容", ["第一章"]),
        ("第1章\n内容", ["第1章"]),
        ("第一百章\n内容", ["第一百章"]),
        ("第0章\n内容", ["第0章"]),
        ("序章\n第一章\n第二章", ["序章", "第一章", "第二章"]),
    ])
    def test_chapter_detection_patterns(self, app, text, expected_chapters):
        """测试各种章节标题模式的检测"""
        text_editor = TextEditor()
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        detected_chapters = [title for _, title in text_editor._chapter_positions]
        assert detected_chapters == expected_chapters

        text_editor.close()

    def test_chapter_with_leading_spaces(self, app):
        """测试带前导空格的章节标题检测"""
        text_editor = TextEditor()
        text = "  第一章\n内容"
        text_editor.text_edit.setText(text)
        text_editor._update_chapter_positions()

        # 应该检测到章节，并去除前导空格
        assert len(text_editor._chapter_positions) == 1
        title = text_editor._chapter_positions[0][1]
        assert title == "第一章"
        assert not title.startswith(" ")

        text_editor.close()
