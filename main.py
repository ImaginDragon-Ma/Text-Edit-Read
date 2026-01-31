# main.py

import sys
import chardet

from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QApplication, QMainWindow, QTextEdit, QAction, QFileDialog, QVBoxLayout, QWidget, QLineEdit, QPushButton, QDialog, QComboBox
from PyQt5.QtGui import QColor, QIcon, QFont

from functions import clean_text, find_text, replace_all_word, replace_except_in_quotes


class TextEditor(QMainWindow):
    def __init__(self):
        super().__init__()

        # 主界面
        self.init_ui()
        
        # 存储文本
        self.text_content = ""

    def init_ui(self):
        self.setWindowIcon(QIcon("./icon.jpg"))

        self.setWindowTitle('文本编辑器')
        self.setGeometry(100, 100, 1000, 1500)

        # 设置文本显示区域
        self.text_edit = QTextEdit(self)
        self.setCentralWidget(self.text_edit)

        # 设置默认字体
        self.default_font = QFont("Arial", 12)
        self.text_edit.setFont(self.default_font)

        # 菜单栏
        menubar = self.menuBar()
        file_menu = menubar.addMenu('文件')
        edit_menu = menubar.addMenu('编辑')

        # 打开、保存文件
        open_action = QAction('打开', self)
        save_action = QAction('保存', self)

        open_action.triggered.connect(self.open_file)
        save_action.triggered.connect(self.save_file)

        file_menu.addAction(open_action)
        file_menu.addAction(save_action)

        # 整理文本、查找和替换功能
        clean_action = QAction('整理文本', self)
        find_action = QAction('查找', self)
        replace_action = QAction('替换', self)

        clean_action.triggered.connect(self.clean_text)
        find_action.triggered.connect(self.find_text)
        replace_action.triggered.connect(self.replace_text)

        edit_menu.addAction(clean_action)
        edit_menu.addAction(find_action)
        edit_menu.addAction(replace_action)

    def open_file(self):
        file_path, _ = QFileDialog.getOpenFileName(self, '打开文件')
        if file_path:
            with open(file_path, 'r', encoding='utf-8') as file:
                self.text_content = file.read()
                self.text_edit.setText(self.text_content)

    def save_file(self):
        file_path, _ = QFileDialog.getSaveFileName(self, '保存文件')
        if file_path:
            with open(file_path, 'w', encoding='utf-8') as file:
                file.write(self.text_edit.toPlainText())

    def clean_text(self):
        self.text_content = self.text_edit.toPlainText()
        self.text_content = clean_text(self.text_content)
        self.text_edit.setText(self.text_content)

    def find_text(self):
        find_dialog = FindDialog(self)
        find_dialog.show()

    def replace_text(self):
        replace_dialog = ReplaceDialog(self)
        replace_dialog.show()


class FindDialog(QDialog):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('查找')

        # 查找输入框
        self.search_input = QLineEdit(self)
        self.search_input.setPlaceholderText("请输入查找内容")
        self.search_button_prev = QPushButton('查找上一个', self)
        self.search_button_next = QPushButton('查找下一个', self)

        self.search_button_prev.clicked.connect(self.find_previous)
        self.search_button_next.clicked.connect(self.find_next)

        layout = QVBoxLayout()
        layout.addWidget(self.search_input)
        layout.addWidget(self.search_button_prev)
        layout.addWidget(self.search_button_next)

        self.setLayout(layout)

    def find_previous(self):
        search_term = self.search_input.text()
        current_text = self.parent.text_edit.toPlainText()
        cursor_pos = self.parent.text_edit.textCursor().position()
        pos, word = find_text(current_text, search_term, start_pos=cursor_pos, direction = 'previous')

        if pos is not None:
            self.parent.text_edit.moveCursor(cursor_pos)
            self.highlight_text(pos, word)

    def find_next(self):
        search_term = self.search_input.text()
        current_text = self.parent.text_edit.toPlainText()
        cursor_pos = self.parent.text_edit.textCursor().position()
        pos, word = find_text(current_text, search_term, start_pos=cursor_pos, direction = 'next')

        if pos is not None:
            self.parent.text_edit.moveCursor(cursor_pos)
            self.highlight_text(pos, word)

    def highlight_text(self, pos, word):
        cursor = self.parent.text_edit.textCursor()
        cursor.setPosition(pos)
        cursor.movePosition(cursor.NextCharacter, cursor.KeepAnchor, len(word))
        self.parent.text_edit.setTextCursor(cursor)
        self.parent.text_edit.setTextBackgroundColor(QColor('yellow'))


class ReplaceDialog(QDialog):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('替换')

        # 替换文本输入框
        self.old_text_input = QLineEdit(self)
        self.new_text_input = QLineEdit(self)
        self.replace_all_checkbox = QComboBox(self)
        self.replace_all_checkbox.addItem("全部替换")
        self.replace_all_checkbox.addItem("双引号外替换")

        self.replace_button = QPushButton('开始替换', self)
        self.replace_button.clicked.connect(self.replace_text)

        layout = QVBoxLayout()
        layout.addWidget(self.old_text_input)
        layout.addWidget(self.new_text_input)
        layout.addWidget(self.replace_all_checkbox)
        layout.addWidget(self.replace_button)

        self.setLayout(layout)

    def replace_text(self):
        old_text = self.old_text_input.text()
        new_text = self.new_text_input.text()
        replace_all = self.replace_all_checkbox.currentText() == "全部替换"

        current_text = self.parent.text_edit.toPlainText()
        lines = current_text.splitlines()  # 将文本按行分开

        if replace_all:
            # 如果选择全部替换
            new_text_content = replace_all_word(lines, old_text, new_text)
            self.parent.text_edit.setText("\n".join(new_text_content))
        else:
            # 否则替换双引号外的词汇
            new_text_content = replace_except_in_quotes(lines, old_text, new_text)
            self.parent.text_edit.setText("\n".join(new_text_content))


if __name__ == '__main__':
    app = QApplication(sys.argv)

    # 设置应用程序的图标
    app.setWindowIcon(QIcon("./icon.jpg"))

    editor = TextEditor()
    editor.show()
    sys.exit(app.exec_())
