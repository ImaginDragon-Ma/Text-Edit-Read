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
        - 分离章节标题为独立段落
        - 调整换行格式

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
            text = TextProcessor._insert_newline_at_word(text, '\n')
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
        """插入第一章标题"""
        lines = text.splitlines()
        if lines and not re.search(r'第一章', lines[0]):
            text = "第一章\n" + text
        return text

    @staticmethod
    def _insert_newline_at_word(text: str, word: str) -> str:
        """检测每行中的指定词，在其后插入换行符"""
        return re.sub(f'({word})', r'\1\n　　', text)

    @staticmethod
    def _separate_chapter_titles(text: str) -> str:
        """检测章节标题，如果不独立则将其独立为一段"""
        lines = []
        for line in text.splitlines():
            if re.match(r'^\s*第[一二三四五六七八九十百千零0-9]+章', line):
                lines.append('\n' + line.strip() + '\n')
            else:
                lines.append(line)
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
