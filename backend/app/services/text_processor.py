"""文本处理服务 - 迁移自原项目 src/core/text_processor.py"""
import re
from typing import Optional, Tuple, List, Match


class TextProcessingError(Exception):
    """文本处理异常"""
    pass


class TextProcessor:
    """文本处理器类 - 从原项目迁移，保持业务逻辑不变"""

    @staticmethod
    def clean_text(text: str) -> str:
        """清理文本"""
        try:
            text = TextProcessor._remove_all_leading_spaces(text)
            text = TextProcessor._remove_empty_paragraphs(text)
            text = TextProcessor._insert_first_chapter(text)
            text = TextProcessor._separate_chapter_titles(text)
            text = TextProcessor._add_chapter_spacing(text)
            text = TextProcessor._add_paragraph_indent(text)
            return text
        except Exception as e:
            raise TextProcessingError(f"文本清理失败: {e}") from e

    @staticmethod
    def _remove_all_leading_spaces(text: str) -> str:
        return text.lstrip()

    @staticmethod
    def _remove_empty_paragraphs(text: str) -> str:
        return "\n".join([line for line in text.splitlines() if line.strip()])

    @staticmethod
    def _insert_first_chapter(text: str) -> str:
        return text

    @staticmethod
    def _separate_chapter_titles(text: str) -> str:
        lines = text.splitlines()
        result = []
        chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)'
        for line in lines:
            match = re.match(chapter_pattern, line)
            if match:
                result.append(line.strip())
            elif line.strip():
                result.append(line.strip())
            elif line == '':
                result.append('')
        return "\n".join(result)

    @staticmethod
    def _add_chapter_spacing(text: str) -> str:
        lines = text.splitlines()
        result = []
        chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)'
        for i, line in enumerate(lines):
            if re.match(chapter_pattern, line):
                if result and result[-1] != '':
                    result.append('')
                result.append(line.strip())
                if i < len(lines) - 1 and lines[i + 1].strip():
                    result.append('')
            elif line.strip():
                result.append(line.strip())
            elif line == '':
                result.append('')
        return "\n".join(result)

    @staticmethod
    def _add_paragraph_indent(text: str) -> str:
        lines = []
        chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)'
        chinese_space = '\u3000'
        for line in text.splitlines():
            stripped_line = line.strip()
            if stripped_line:
                if re.match(chapter_pattern, stripped_line):
                    lines.append(stripped_line)
                else:
                    lines.append(chinese_space * 2 + stripped_line)
            else:
                lines.append('')
        return "\n".join(lines)

    @staticmethod
    def find_text(
        text: str,
        search_term: str,
        start_pos: int = 0,
        direction: str = 'next'
    ) -> Tuple[Optional[int], Optional[str]]:
        """查找文本"""
        try:
            if not search_term:
                return None, None
            pattern = re.compile(re.escape(search_term))
            if direction == 'next':
                match = pattern.search(text[start_pos:])
                if match:
                    return match.start() + start_pos, match.group()
            elif direction == 'previous':
                reverse_pos = start_pos - 1
                if reverse_pos >= 0:
                    match = pattern.search(text[:reverse_pos][::-1])
                    if match:
                        return reverse_pos - match.end(), match.group()
            return None, None
        except Exception as e:
            raise TextProcessingError(f"文本查找失败: {e}") from e

    @staticmethod
    def replace_all_word(lines: List[str], old_word: str, new_word: str) -> Tuple[List[str], int]:
        """替换所有"""
        try:
            result = []
            count = 0
            for line in lines:
                new_line = line.replace(old_word, new_word)
                count += line.count(old_word)
                result.append(new_line)
            return result, count
        except Exception as e:
            raise TextProcessingError(f"全部替换失败: {e}") from e

    @staticmethod
    def replace_except_in_quotes(
        lines: List[str],
        old_word: str,
        new_word: str
    ) -> Tuple[List[str], int]:
        """替换双引号外的指定单词"""
        try:
            count = 0

            def replace_match(match: Match) -> str:
                nonlocal count
                text = match.group(0)
                if (
                    text.startswith('\u201c') and text.endswith('\u201d')
                ) or (
                    text.startswith('\u201c') and text.endswith('\u201d')
                ):
                    return text
                replaced = text.replace(old_word, new_word)
                count += text.count(old_word)
                return replaced

            result = [re.sub(r'\u201c[^\u201d]*\u201d|"[^"]*"|[^\u201c\u201d"]+', replace_match, line) for line in lines]
            return result, count
        except Exception as e:
            raise TextProcessingError(f"双引号外替换失败: {e}") from e
