"""文件处理服务 - 迁移自原项目 src/core/file_handler.py"""
from pathlib import Path
from typing import Optional

import chardet


DEFAULT_ENCODING = "utf-8"
ENCODE_DETECT_SAMPLE_SIZE = 4096
ENCODING_CONFIDENCE_THRESHOLD = 0.7


class FileOperationError(Exception):
    def __init__(self, message: str, file_path: str | None = None):
        self.file_path = file_path
        super().__init__(message)


class EncodingDetectionError(Exception):
    pass


class FileHandler:
    """文件处理器类 - 从原项目迁移，保持业务逻辑不变"""

    @staticmethod
    def detect_encoding(file_path: Path) -> str:
        try:
            with open(file_path, 'rb') as file:
                raw_data = file.read(ENCODE_DETECT_SAMPLE_SIZE)
                result = chardet.detect(raw_data)
                encoding = result.get('encoding')
                confidence = result.get('confidence', 0)
                if confidence < ENCODING_CONFIDENCE_THRESHOLD or not encoding:
                    return DEFAULT_ENCODING
                if encoding and encoding.upper() == 'GB2312':
                    encoding = 'gb18030'
                return encoding
        except IOError as e:
            raise FileOperationError(f"无法读取文件进行编码检测: {e}", str(file_path)) from e
        except Exception as e:
            raise EncodingDetectionError(f"编码检测失败: {e}") from e

    @staticmethod
    def read_file(file_path: Path, encoding: Optional[str] = None) -> str:
        try:
            if encoding is None:
                encoding = FileHandler.detect_encoding(file_path)
            with open(file_path, 'r', encoding=encoding) as file:
                return file.read()
        except UnicodeDecodeError:
            try:
                with open(file_path, 'r', encoding='gb18030') as file:
                    return file.read()
            except UnicodeDecodeError as e:
                raise FileOperationError(f"文件解码失败: {e}", str(file_path)) from e
        except IOError as e:
            raise FileOperationError(f"无法读取文件: {e}", str(file_path)) from e
        except Exception as e:
            raise FileOperationError(f"读取文件时发生未知错误: {e}", str(file_path)) from e

    @staticmethod
    def save_file(file_path: Path, content: str, encoding: str = DEFAULT_ENCODING) -> None:
        try:
            file_path.parent.mkdir(parents=True, exist_ok=True)
            with open(file_path, 'w', encoding=encoding) as file:
                file.write(content)
        except IOError as e:
            raise FileOperationError(f"无法保存文件: {e}", str(file_path)) from e
        except Exception as e:
            raise FileOperationError(f"保存文件时发生未知错误: {e}", str(file_path)) from e
