"""配置管理模块

集中管理应用程序的配置项，包括默认字体、窗口大小、文件路径等。
"""
from pathlib import Path
from typing import Final

# 项目根目录
PROJECT_ROOT: Final[Path] = Path(__file__).parent.parent.parent

# 资源目录
RESOURCES_DIR: Final[Path] = PROJECT_ROOT / "resources"
ICONS_DIR: Final[Path] = RESOURCES_DIR / "icons"

# 应用配置
APP_NAME: Final[str] = "文本编辑器"
APP_VERSION: Final[str] = "0.2.0"

# 窗口配置
WINDOW_WIDTH: Final[int] = 1000
WINDOW_HEIGHT: Final[int] = 800
WINDOW_X: Final[int] = 100
WINDOW_Y: Final[int] = 100

# 字体配置
DEFAULT_FONT_FAMILY: Final[str] = "Arial"
DEFAULT_FONT_SIZE: Final[int] = 12
MIN_FONT_SIZE: Final[int] = 6
MAX_FONT_SIZE: Final[int] = 36
FONT_STEP: Final[int] = 2

# 文件配置
DEFAULT_ENCODING: Final[str] = "utf-8"
ENCODE_DETECT_SAMPLE_SIZE: Final[int] = 4096  # 编码检测采样大小 (字节)
ENCODING_CONFIDENCE_THRESHOLD: Final[float] = 0.7  # 编码检测置信度阈值

# 高亮配置
HIGHLIGHT_COLOR: Final[str] = "yellow"

# 图标文件名
APP_ICON_NAME: Final[str] = "app_icon.jpg"
