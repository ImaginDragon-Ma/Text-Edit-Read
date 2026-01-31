import sys
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QApplication, QMainWindow, QTextEdit


class TextZoomEdit(QTextEdit):
    def __init__(self):
        super().__init__()
        self.setText("This is some example text. Scroll with Ctrl + Mouse Wheel to zoom in and out.")
        self.font_size = 12  # 默认字体大小
        self.update_font()

    def wheelEvent(self, event):
        # 检查是否按下了Ctrl键
        if event.modifiers() == Qt.ControlModifier:
            # 获取滚轮的方向，正数表示放大，负数表示缩小
            delta = event.angleDelta().y()
            if delta > 0:  # 放大
                self.font_size += 2
            elif delta < 0:  # 缩小
                self.font_size -= 2

            # 限制字体大小范围，防止过小或过大的字体
            self.font_size = max(6, min(self.font_size, 36))

            self.update_font()

    def update_font(self):
        # 设置文本框字体大小
        font = self.font()
        font.setPointSize(self.font_size)
        self.setFont(font)


class TextZoomWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Zoom Text with Mouse Wheel")
        self.setGeometry(100, 100, 800, 600)

        # 使用自定义的 TextZoomEdit 作为 QTextEdit
        self.text_edit = TextZoomEdit()
        self.setCentralWidget(self.text_edit)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = TextZoomWindow()
    window.show()
    sys.exit(app.exec_())
