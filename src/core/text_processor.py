"""文本处理核心模块

提供文本清理、查找、替换等核心功能。
"""
import re
from typing import Optional, Tuple, List

from src.utils.exceptions import TextProcessingError


class TextProcessor:
    """文本处理器类

    封装所有文本处理相关的操作，包括清理、查找、替换等。
    """

    @staticmethod
    def clean_text(text: str) -> str:
        """清理文本

        执行以下操作：
        - 删除开头空格
        - 删除空白段落
        - 自动插入第一章标题
        - 分离章节标题为独立段落，章节间保留两行空余
        - 为段落开头添加两个空格缩进

        Args:
            text: 要清理的文本

        Returns:
            清理后的文本
        """
        try:
            text = TextProcessor._remove_all_leading_spaces(text)
            text = TextProcessor._remove_empty_paragraphs(text)
            text = TextProcessor._insert_first_chapter(text)
            text = TextProcessor._separate_chapter_titles(text)
            text = TextProcessor._add_paragraph_indent(text)
            return text
        except Exception as e:
            raise TextProcessingError(f"文本清理失败: {e}") from e

    @staticmethod
    def _remove_all_leading_spaces(text: str) -> str:
        """删除开头空格"""
        return text.lstrip()

    @staticmethod
    def _remove_empty_paragraphs(text: str) -> str:
        """删除空白段落"""
        return "\n".join([line for line in text.splitlines() if line.strip()])

    @staticmethod
    def _insert_first_chapter(text: str) -> str:
        """插入第一章标题

        检测整个文本中是否已经有章节标题（序章或第X章），
        如果没有则插入"第一章"标题，否则不添加。
        """
        # 检测文本中是否已有章节标题（序章 或 第X章）
        chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)'
        has_chapter = any(re.match(chapter_pattern, line) for line in text.splitlines())

        if not has_chapter:
            text = "第一章\n" + text

        return text

    @staticmethod
    def _separate_chapter_titles(text: str) -> str:
        """检测章节标题，如果不独立则将其独立为一段

        支持的章节标题格式：
        - 序章
        - 第X章（如：第一章、第二章等）

        章节标题前后保留两行空余。
        """
        lines = text.splitlines()
        result = []
        # 匹配章节标题：序章 或 第X章
        chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)'

        for line in lines:
            stripped_line = line.strip()
            if re.match(chapter_pattern, stripped_line):
                # 章节标题前后添加两行空余
                # 如果不是第一行，在前面添加两行空行
                if result:
                    result.append('')  # 空行1
                    result.append('')  # 空行2
                # 添加章节标题（不带空格）
                result.append(stripped_line)
            elif stripped_line:
                # 非空行，直接添加
                result.append(stripped_line)

        return "\n".join(result)

    @staticmethod
    def _add_paragraph_indent(text: str) -> str:
        """为段落开头添加两个空格缩进

        章节标题行不添加缩进。
        """
        lines = []
        # 匹配章节标题：序章 或 第X章
        chapter_pattern = r'^\s*(序章|第[一二三四五六七八九十百千零0-9]+章)$'

        for line in text.splitlines():
            stripped_line = line.strip()
            if stripped_line:
                # 检查是否为章节标题
                if re.match(chapter_pattern, stripped_line):
                    # 章节标题不添加缩进
                    lines.append(stripped_line)
                else:
                    # 普通段落添加两个空格缩进
                    lines.append('  ' + stripped_line)
            else:
                # 空行保留
                lines.append('')

        return "\n".join(lines)

    @staticmethod
    def find_text(
        text: str,
        search_term: str,
        start_pos: int = 0,
        direction: str = 'next'
    ) -> Tuple[Optional[int], Optional[str]]:
        """查找文本中的目标词

        Args:
            text: 要查找的文本
            search_term: 查找的目标词
            start_pos: 查找的起始位置
            direction: 查找的方向（'next' 或 'previous'）

        Returns:
            元组 (位置, 匹配的文本)，未找到时返回 (None, None)
        """
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
    def replace_all_word(lines: List[str], old_word: str, new_word: str) -> List[str]:
        """替换所有行中的指定单词

        Args:
            lines: 文本行列表
            old_word: 要替换的旧词
            new_word: 新词

        Returns:
            替换后的行列表
        """
        try:
            return [line.replace(old_word, new_word) for line in lines]
        except Exception as e:
            raise TextProcessingError(f"全部替换失败: {e}") from e

    @staticmethod
    def replace_except_in_quotes(
        lines: List[str],
        old_word: str,
        new_word: str
    ) -> List[str]:
        """替换双引号外的指定单词

        Args:
            lines: 文本行列表
            old_word: 要替换的旧词
            new_word: 新词

        Returns:
            替换后的行列表
        """
        try:
            def replace_line(line: str) -> str:
                def replace_match(match: re.Match) -> str:
                    text = match.group(0)
                    # 检查是否为中英文双引号包裹的内容
                    if (
                        text.startswith('“') and text.endswith('”')
                    ) or (
                        text.startswith('"') and text.endswith('"')
                    ):
                        return text
                    return text.replace(old_word, new_word)

                # 匹配中英文双引号内的内容或非引号内容
                return re.sub(
                    r'“[^”]*”|"[^"]*"|[^“”"]+',
                    replace_match,
                    line
                )

            return [replace_line(line) for line in lines]
        except Exception as e:
            raise TextProcessingError(f"双引号外替换失败: {e}") from e
