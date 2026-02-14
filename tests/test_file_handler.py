"""文件处理器测试模块

测试 FileHandler 类的各项功能。
"""
import pytest
from pathlib import Path
import tempfile

from src.core.file_handler import FileHandler
from src.utils.exceptions import FileOperationError, EncodingDetectionError


class TestFileHandler:
    """测试文件处理器"""

    @pytest.fixture
    def temp_dir(self):
        """创建临时目录"""
        with tempfile.TemporaryDirectory() as tmpdir:
            yield Path(tmpdir)

    def test_detect_encoding_utf8(self, temp_dir):
        """测试检测 UTF-8 编码"""
        file_path = temp_dir / "test_utf8.txt"
        file_path.write_text("这是一些中文文本", encoding="utf-8")

        encoding = FileHandler.detect_encoding(file_path)
        assert encoding == "utf-8"

    def test_detect_encoding_gbk(self, temp_dir):
        """测试检测 GBK 编码"""
        file_path = temp_dir / "test_gbk.txt"
        file_path.write_text("这是一些中文文本", encoding="gbk")

        encoding = FileHandler.detect_encoding(file_path)
        # GBK 编码可能会被检测为 GB18030 或其他兼容编码
        assert encoding is not None

    def test_read_file_utf8(self, temp_dir):
        """测试读取 UTF-8 文件"""
        file_path = temp_dir / "test.txt"
        content = "Hello World\n中文测试"
        file_path.write_text(content, encoding="utf-8")

        result = FileHandler.read_file(file_path)
        assert result == content

    def test_read_file_auto_detect(self, temp_dir):
        """测试自动检测编码读取文件"""
        file_path = temp_dir / "test_gbk.txt"
        content = "中文测试内容"
        file_path.write_text(content, encoding="gbk")

        # 不指定编码，自动检测
        result = FileHandler.read_file(file_path)
        assert "中文" in result

    def test_save_file(self, temp_dir):
        """测试保存文件"""
        file_path = temp_dir / "output.txt"
        content = "保存的测试内容"

        FileHandler.save_file(file_path, content)

        assert file_path.exists()
        assert file_path.read_text(encoding="utf-8") == content

    def test_save_file_with_encoding(self, temp_dir):
        """测试使用指定编码保存文件"""
        file_path = temp_dir / "output_gbk.txt"
        content = "中文内容"

        FileHandler.save_file(file_path, content, encoding="gbk")

        assert file_path.exists()
        # 使用 GBK 编码读取
        result = file_path.read_text(encoding="gbk")
        assert result == content

    def test_save_file_create_parent_dir(self, temp_dir):
        """测试保存时自动创建父目录"""
        file_path = temp_dir / "subdir" / "nested" / "output.txt"
        content = "测试内容"

        FileHandler.save_file(file_path, content)

        assert file_path.exists()
        assert file_path.read_text(encoding="utf-8") == content

    def test_read_file_not_found(self, temp_dir):
        """测试读取不存在的文件"""
        file_path = temp_dir / "nonexistent.txt"

        with pytest.raises(FileOperationError) as exc_info:
            FileHandler.read_file(file_path)

        assert "无法读取文件" in str(exc_info.value)

    def test_save_invalid_path(self):
        """测试保存到无效路径"""
        # 使用一个不太可能的无效路径
        file_path = Path("/invalid/path/that/does/not/exist/output.txt")
        content = "测试"

        with pytest.raises(FileOperationError) as exc_info:
            FileHandler.save_file(file_path, content)

        assert "无法保存文件" in str(exc_info.value)

    def test_read_file_wrong_encoding(self, temp_dir):
        """测试使用错误编码读取文件"""
        file_path = temp_dir / "test.txt"
        content = "中文内容"
        file_path.write_text(content, encoding="gbk")

        # 使用错误的编码（utf-8）读取
        with pytest.raises(FileOperationError) as exc_info:
            FileHandler.read_file(file_path, encoding="utf-8")

        assert "解码失败" in str(exc_info.value)
