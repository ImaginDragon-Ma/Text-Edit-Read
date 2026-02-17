"""自定义异常模块

定义应用程序专用的异常类，提供更好的错误处理和用户反馈。
"""


class TextEditorError(Exception):
    """文本编辑器基础异常类"""

    pass


class FileOperationError(TextEditorError):
    """文件操作异常

    当文件打开、保存、读取等操作失败时抛出。
    """

    def __init__(self, message: str, file_path: str | None = None):
        self.file_path = file_path
        super().__init__(message)


class EncodingDetectionError(TextEditorError):
    """编码检测异常

    当无法检测文件编码或编码检测失败时抛出。
    """

    pass


class TextProcessingError(TextEditorError):
    """文本处理异常

    当文本清理、查找、替换等操作失败时抛出。
    """

    pass


class ResourceNotFoundError(TextEditorError):
    """资源文件未找到异常

    当应用程序所需的资源文件（如图标）未找到时抛出。
    """

    def __init__(self, resource_type: str, path: str):
        self.resource_type = resource_type
        self.path = path
        super().__init__(f"{resource_type} not found at: {path}")
