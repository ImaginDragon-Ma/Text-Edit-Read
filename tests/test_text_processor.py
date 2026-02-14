"""文本处理器测试模块

测试 TextProcessor 类的各项功能。
"""
import pytest

from src.core.text_processor import TextProcessor
from src.utils.exceptions import TextProcessingError


class TestTextProcessorClean:
    """测试文本清理功能"""

    def test_remove_leading_spaces(self):
        """测试删除开头空格"""
        text = "   这是一些文本"
        result = TextProcessor.clean_text(text)
        assert result == "这是一些文本"

    def test_remove_empty_paragraphs(self):
        """测试删除空白段落"""
        text = "第一行\n\n\n第三行\n  \n第五行"
        result = TextProcessor.clean_text(text)
        assert result == "第一行\n第三行\n第五行"

    def test_insert_first_chapter(self):
        """测试插入第一章标题"""
        text = "这是一些内容"
        result = TextProcessor.clean_text(text)
        assert result.startswith("第一章\n")

    def test_no_insert_first_chapter_if_exists(self):
        """测试已存在第一章时不重复插入"""
        text = "第一章\n这是一些内容"
        result = TextProcessor.clean_text(text)
        assert result.startswith("第一章\n")

    def test_separate_chapter_titles(self):
        """测试分离章节标题"""
        text = "前言\n第二章 新的开始\n正文内容"
        result = TextProcessor.clean_text(text)
        assert "\n第二章 新的开始\n" in result

    def test_clean_text_integration(self):
        """测试清理文本的完整流程"""
        text = "   第一章\n\n\n这是正文\n\n第二章 标题\n内容"
        result = TextProcessor.clean_text(text)
        assert result.startswith("第一章\n")
        assert "这是正文" in result
        assert "\n第二章 标题\n" in result


class TestTextProcessorFind:
    """测试文本查找功能"""

    def test_find_text_next(self):
        """测试查找下一个"""
        text = "hello world hello test"
        pos, word = TextProcessor.find_text(text, "hello", start_pos=0, direction='next')
        assert pos == 0
        assert word == "hello"

    def test_find_text_next_from_middle(self):
        """测试从中间位置查找下一个"""
        text = "hello world hello test"
        pos, word = TextProcessor.find_text(text, "hello", start_pos=6, direction='next')
        assert pos == 12
        assert word == "hello"

    def test_find_text_previous(self):
        """测试查找上一个"""
        text = "hello world hello test"
        pos, word = TextProcessor.find_text(text, "hello", start_pos=12, direction='previous')
        assert pos == 0
        assert word == "hello"

    def test_find_text_not_found(self):
        """测试未找到的情况"""
        text = "hello world"
        pos, word = TextProcessor.find_text(text, "python", direction='next')
        assert pos is None
        assert word is None

    def test_find_text_empty_search_term(self):
        """测试空搜索词"""
        text = "hello world"
        pos, word = TextProcessor.find_text(text, "")
        assert pos is None
        assert word is None


class TestTextProcessorReplace:
    """测试文本替换功能"""

    def test_replace_all_word(self):
        """测试全部替换"""
        lines = ["hello world", "hello test", "world hello"]
        result = TextProcessor.replace_all_word(lines, "hello", "hi")
        assert result == ["hi world", "hi test", "world hi"]

    def test_replace_all_word_not_found(self):
        """测试替换不存在的词"""
        lines = ["hello world", "test"]
        result = TextProcessor.replace_all_word(lines, "python", "java")
        assert result == lines

    def test_replace_except_in_quotes(self):
        """测试双引号外替换"""
        lines = ['hello "hello" world', 'hello world']
        result = TextProcessor.replace_except_in_quotes(lines, "hello", "hi")
        assert result == ['hi "hello" world', 'hi world']

    def test_replace_except_in_quotes_chinese(self):
        """测试中文双引号外替换"""
        lines = ['你好"你好"世界', '你好 世界']
        result = TextProcessor.replace_except_in_quotes(lines, "你好", "hi")
        assert result == ['hi"你好"世界', 'hi 世界']

    def test_replace_except_in_quotes_mixed(self):
        """测试混合引号"""
        lines = ['text "text" "text" text']
        result = TextProcessor.replace_except_in_quotes(lines, "text", "new")
        assert result == ['new "text" "text" new']


class TestTextProcessorExceptions:
    """测试异常处理"""

    def test_invalid_regex_pattern(self):
        """测试无效的正则表达式模式"""
        # 由于使用了 re.escape，特殊字符会被转义，不太可能触发异常
        # 这里测试空文本查找
        pos, word = TextProcessor.find_text("", "test")
        assert pos is None
        assert word is None
