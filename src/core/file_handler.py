"""文件处理核心模块

提供文件编码检测、读取、保存等功能。
"""
from pathlib import Path
from typing import Optional

import chardet

from src.utils.config import (
    DEFAULT_ENCODING,
    ENCODE_DETECT_SAMPLE_SIZE,
    ENCODING_CONFIDENCE_THRESHOLD,
)
from src.utils.exceptions import FileOperationError, EncodingDetectionError


class FileHandler:
    """文件处理器类

    封装所有文件操作相关的功能，包括编码检测、读取、保存等。
    """

    @staticmethod
    def detect_encoding(file_path: Path) -> str:
        """检测文件编码

        Args:
            file_path: 文件路径

        Returns:
            检测到的编码名称

        Raises:
            FileOperationError: 当文件读取失败时
            EncodingDetectionError: 当编码检测失败时
        """
        try:
            with open(file_path, 'rb') as file:
                raw_data = file.read(ENCODE_DETECT_SAMPLE_SIZE)
                result = chardet.detect(raw_data)
                encoding = result.get('encoding')
                confidence = result.get('confidence', 0)

                # 如果检测置信度低于阈值或未检测到编码，使用默认编码
                if confidence < ENCODING_CONFIDENCE_THRESHOLD or not encoding:
                    return DEFAULT_ENCODING

                # GB2312 编码映射：使用 gb18030 作为替代（更兼容）
                # Python 不支持直接打开 GB2312，但 gb18030 完全兼容
                if encoding and encoding.upper() == 'GB2312':
                    encoding = 'gb18030'

                return encoding
        except IOError as e:
            raise FileOperationError(
                f"无法读取文件进行编码检测: {e}",
                str(file_path)
            ) from e
        except Exception as e:
            raise EncodingDetectionError(
                f"编码检测失败: {e}"
            ) from e

    @staticmethod
    def read_file(file_path: Path, encoding: Optional[str] = None) -> str:
        """读取文件内容

        Args:
            file_path: 文件路径
            encoding: 文件编码，如果为 None 则自动检测

        Returns:
            文件内容

        Raises:
            FileOperationError: 当文件读取失败时
        """
        try:
            if encoding is None:
                encoding = FileHandler.detect_encoding(file_path)

            with open(file_path, 'r', encoding=encoding) as file:
                return file.read()
        except UnicodeDecodeError:
            # 如果解码失败，尝试使用 gb18030（兼容 GB2312、GBK）
            try:
                with open(file_path, 'r', encoding='gb18030') as file:
                    return file.read()
            except UnicodeDecodeError as e:
                raise FileOperationError(
                    f"文件解码失败，尝试编码 {encoding} 和 gb18030 均失败: {e}",
                    str(file_path)
                ) from e
        except IOError as e:
            raise FileOperationError(
                f"无法读取文件: {e}",
                str(file_path)
            ) from e
        except Exception as e:
            raise FileOperationError(
                f"读取文件时发生未知错误: {e}",
                str(file_path)
            ) from e

    @staticmethod
    def save_file(file_path: Path, content: str, encoding: str = DEFAULT_ENCODING) -> None:
        """保存文件内容

        Args:
            file_path: 文件路径
            content: 要保存的内容
            encoding: 文件编码

        Raises:
            FileOperationError: 当文件保存失败时
        """
        try:
            # 确保父目录存在
            file_path.parent.mkdir(parents=True, exist_ok=True)

            with open(file_path, 'w', encoding=encoding) as file:
                file.write(content)
        except IOError as e:
            raise FileOperationError(
                f"无法保存文件: {e}",
                str(file_path)
            ) from e
        except Exception as e:
            raise FileOperationError(
                f"保存文件时发生未知错误: {e}",
                str(file_path)
            ) from e
