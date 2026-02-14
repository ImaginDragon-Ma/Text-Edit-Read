"""工具模块

提供配置管理和异常处理功能。
"""

from .config import (
    APP_ICON_NAME,
    APP_NAME,
    APP_VERSION,
    DEFAULT_ENCODING,
    DEFAULT_FONT_FAMILY,
    DEFAULT_FONT_SIZE,
    ENCODE_DETECT_SAMPLE_SIZE,
    ENCODING_CONFIDENCE_THRESHOLD,
    FONT_STEP,
    HIGHLIGHT_COLOR,
    ICONS_DIR,
    MAX_FONT_SIZE,
    MIN_FONT_SIZE,
    RESOURCES_DIR,
    PROJECT_ROOT,
    WINDOW_HEIGHT,
    WINDOW_WIDTH,
    WINDOW_X,
    WINDOW_Y,
)
from .exceptions import (
    EncodingDetectionError,
    FileOperationError,
    ResourceNotFoundError,
    TextEditorError,
    TextProcessingError,
)

__all__ = [
    # Config
    "PROJECT_ROOT",
    "RESOURCES_DIR",
    "ICONS_DIR",
    "APP_NAME",
    "APP_VERSION",
    "WINDOW_WIDTH",
    "WINDOW_HEIGHT",
    "WINDOW_X",
    "WINDOW_Y",
    "DEFAULT_FONT_FAMILY",
    "DEFAULT_FONT_SIZE",
    "MIN_FONT_SIZE",
    "MAX_FONT_SIZE",
    "FONT_STEP",
    "DEFAULT_ENCODING",
    "ENCODE_DETECT_SAMPLE_SIZE",
    "ENCODING_CONFIDENCE_THRESHOLD",
    "HIGHLIGHT_COLOR",
    "APP_ICON_NAME",
    # Exceptions
    "TextEditorError",
    "FileOperationError",
    "EncodingDetectionError",
    "TextProcessingError",
    "ResourceNotFoundError",
]
