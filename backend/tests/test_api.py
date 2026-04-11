"""基础 API 测试"""
import pytest
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
