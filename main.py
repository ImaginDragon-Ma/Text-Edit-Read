"""changeTXT - 文本编辑器主入口

基于 PyQt5 的文本编辑与处理工具。
"""
import sys

from PyQt5.QtWidgets import QApplication

from src.ui import TextEditor


def main() -> None:
    """应用程序主入口"""
    app = QApplication(sys.argv)

    # 设置应用程序属性
    app.setApplicationName("changeTXT")
    app.setApplicationDisplayName("文本编辑器")

    # 创建并显示主窗口
    editor = TextEditor()
    editor.show()

    # 运行应用程序
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
