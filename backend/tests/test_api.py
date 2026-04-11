"""基础 API 测试"""
import pytest
import tempfile
import os
from pathlib import Path
from fastapi.testclient import TestClient

from app.main import app
from app.services.text_processor import TextProcessor, TextProcessingError

client = TestClient(app)


class TestHealthCheck:
    def test_health(self):
        resp = client.get("/api/health")
        assert resp.status_code == 200
        assert resp.json()["status"] == "ok"


class TestCleanText:
    def test_basic_clean(self):
        resp = client.post("/api/text/clean", json={"text": "  \n\n测试文本\n\n"})
        assert resp.status_code == 200
        result = resp.json()["cleaned_text"]
        assert "测试文本" in result
        assert result.startswith("测试文本")

    def test_chapter_spacing(self):
        text = "第一章 开始\n这是内容\n第二章 继续\n更多内容"
        resp = client.post("/api/text/clean", json={"text": text})
        assert resp.status_code == 200
        result = resp.json()["cleaned_text"]
        assert "\n\n第一章 开始\n" in result or result.startswith("第一章 开始")

    def test_empty_text(self):
        resp = client.post("/api/text/clean", json={"text": ""})
        assert resp.status_code == 200

    def test_removes_leading_spaces(self):
        text = "   第一章 标题\n   段落内容"
        resp = client.post("/api/text/clean", json={"text": text})
        assert resp.status_code == 200
        result = resp.json()["cleaned_text"]
        assert not result.startswith("   ")


class TestFindText:
    def test_find_next(self):
        resp = client.post("/api/text/find", json={
            "text": "hello world hello",
            "search_term": "hello",
            "start_pos": 0,
            "direction": "next"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["position"] == 0
        assert data["matched_text"] == "hello"

    def test_find_previous(self):
        resp = client.post("/api/text/find", json={
            "text": "hello world hello",
            "search_term": "hello",
            "start_pos": 12,
            "direction": "previous"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["position"] == 0

    def test_find_not_found(self):
        resp = client.post("/api/text/find", json={
            "text": "hello",
            "search_term": "xyz",
            "start_pos": 0,
            "direction": "next"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["position"] is None

    def test_find_empty_term(self):
        resp = client.post("/api/text/find", json={
            "text": "hello",
            "search_term": "",
            "start_pos": 0,
            "direction": "next"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["position"] is None


class TestReplaceAll:
    def test_replace_all(self):
        resp = client.post("/api/text/replace-all", json={
            "lines": ["hello world", "hello again"],
            "old_word": "hello",
            "new_word": "hi"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["replace_count"] == 2
        assert data["lines"] == ["hi world", "hi again"]

    def test_replace_all_no_match(self):
        resp = client.post("/api/text/replace-all", json={
            "lines": ["hello world"],
            "old_word": "xyz",
            "new_word": "abc"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["replace_count"] == 0

    def test_replace_all_empty_old_word(self):
        resp = client.post("/api/text/replace-all", json={
            "lines": ["hello"],
            "old_word": "",
            "new_word": "hi"
        })
        # Empty search term should be handled gracefully
        assert resp.status_code == 200


class TestReplaceExceptQuotes:
    def test_replace_except_quotes(self):
        resp = client.post("/api/text/replace-except-quotes", json={
            "lines": ['他说"hello"然后hello'],
            "old_word": "hello",
            "new_word": "hi"
        })
        assert resp.status_code == 200
        data = resp.json()
        # 引号内的 hello 不替换，外面的替换
        assert data["replace_count"] == 1

    def test_replace_except_quotes_chinese_quotes(self):
        resp = client.post("/api/text/replace-except-quotes", json={
            "lines": ['他说\u201chello\u201d然后hello'],
            "old_word": "hello",
            "new_word": "hi"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["replace_count"] == 1


class TestFileOperations:
    """File operation API tests (require real temp files)"""

    def _create_temp_file(self, content: str, suffix: str = ".txt") -> str:
        fd, path = tempfile.mkstemp(suffix=suffix)
        os.write(fd, content.encode("utf-8"))
        os.close(fd)
        return path

    def test_read_file_utf8(self):
        path = self._create_temp_file("Hello 世界", suffix=".txt")
        try:
            resp = client.post("/api/file/read", json={
                "file_path": path,
                "encoding": "utf-8"
            })
            assert resp.status_code == 200
            data = resp.json()
            assert data["content"] == "Hello 世界"
        finally:
            os.unlink(path)

    def test_save_file(self):
        path = self._create_temp_file("", suffix=".txt")
        try:
            resp = client.post("/api/file/save", json={
                "file_path": path,
                "content": "保存的内容",
                "encoding": "utf-8"
            })
            assert resp.status_code == 200
            # Verify file was written
            with open(path, "r", encoding="utf-8") as f:
                assert f.read() == "保存的内容"
        finally:
            os.unlink(path)

    def test_detect_encoding_utf8(self):
        path = self._create_temp_file("UTF-8内容", suffix=".txt")
        try:
            resp = client.post("/api/file/detect-encoding", json={
                "file_path": path
            })
            assert resp.status_code == 200
            data = resp.json()
            assert data["encoding"] is not None
        finally:
            os.unlink(path)

    def test_read_nonexistent_file(self):
        resp = client.post("/api/file/read", json={
            "file_path": "/nonexistent/file.txt",
            "encoding": "utf-8"
        })
        assert resp.status_code == 400

    def test_save_nonexistent_directory(self):
        resp = client.post("/api/file/save", json={
            "file_path": "/nonexistent/dir/file.txt",
            "content": "test"
        })
        assert resp.status_code == 400


class TestTextProcessorDirect:
    """直接测试 TextProcessor（不经过 API）"""

    def test_clean_text_adds_indent(self):
        text = "第一章 开始\n这是一段话\n这是另一段"
        result = TextProcessor.clean_text(text)
        lines = result.splitlines()
        # 章节标题不应有缩进
        assert not lines[0].startswith('\u3000')
        # 普通段落应有缩进
        assert lines[2].startswith('\u3000\u3000')

    def test_empty_search_term(self):
        pos, matched = TextProcessor.find_text("hello", "", 0, "next")
        assert pos is None
        assert matched is None

    def test_find_text_chinese(self):
        pos, matched = TextProcessor.find_text("你好世界你好", "你好", 0, "next")
        assert pos == 0
        assert matched == "你好"
