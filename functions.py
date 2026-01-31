# text_functions.py

import re

# 整理文本功能（去除多余空格，换行符）
def clean_text(text: str) -> str:

    # 删除开头空格
    def remove_all_leading_spaces(text):
        """删除开头空格"""
        return text.lstrip()

    # 删除空白段落
    def remove_empty_paragraphs(text):
        """删除空白段落"""
        return "\n".join([line for line in text.splitlines() if line.strip()])

    # 插入 "第一章"
    def insert_first_chapter(text):
        """插入第一章"""
        if not re.search(r'第一章', text.splitlines()[0]):
            text = "第一章\n" + text
        return text

    # 插入换行符
    def insert_newline_at_word(text, word):
        """检测每行中的指定词，在其后插入换行符"""
        return re.sub(f'({word})', r'\1\n　　', text)

    # 分离章节标题
    def separate_chapter_titles(text):
        """检测章节标题，如果不独立则将其独立为一段"""
        lines = []
        for line in text.splitlines():
            if re.match(r'^\s*第[一二三四五六七八九十百千零0-9]+章', line):
                lines.append('\n' + line.strip() + '\n')  # 独立章节标题
            else:
                lines.append(line)
        return "\n".join(lines)

    # 调用每个步骤
    text = remove_all_leading_spaces(text)          # 删除开头空格
    text = remove_empty_paragraphs(text)            # 删除空白段落
    text = insert_first_chapter(text)               # 插入第一章
    text = separate_chapter_titles(text)            # 分离章节标题
    text = insert_newline_at_word(text, '\n')       # 插入换行符

    return text


def find_text(text: str, search_term: str, start_pos: int = 0, direction: str = 'next'):
    """
    查找文本中的目标词，支持查找下一个和上一个。
    
    :param text: 要查找的文本
    :param search_term: 查找的目标词
    :param start_pos: 查找的起始位置
    :param direction: 查找的方向（'next' 或 'previous'）
    :return: 返回匹配位置和匹配的文本
    """
    pattern = re.compile(re.escape(search_term))

    if direction == 'next':
        match = pattern.search(text[start_pos:])  # 查找下一个
        if match:
            return match.start() + start_pos, match.group()
    
    elif direction == 'previous':
        # 查找上一个，反向查找
        reverse_pos = start_pos - 1  # 向前查找
        if reverse_pos >= 0:
            match = pattern.search(text[:reverse_pos][::-1])  # 反转文本，查找
            if match:
                return reverse_pos - match.end(), match.group()

    return None, None

# 替换所有行中的指定单词
def replace_all_word(lines, old_word, new_word):
    return [line.replace(old_word, new_word) for line in lines]

# # 替换双引号外的指定单词
# def replace_except_in_quotes(lines, old_word, new_word):
#     # 正则表达式，匹配双引号内外的内容
#     def replace_line(line):
#         # 使用一个标记来区分双引号内外的部分
#         def replace_match(match):
#             # 如果是双引号外的部分，进行替换
#             text = match.group(0)
#             if not text.startswith('“') and not text.endswith('”'):
#                 return text.replace(old_word, new_word)
#             return text

#         # 匹配双引号外的部分，并进行替换
#         return re.sub(r'[^“”]+|“[^“”]*”', replace_match, line)

#     # 对每一行应用替换
#     return [replace_line(line) for line in lines]

def replace_except_in_quotes(lines, old_word, new_word):
    def replace_line(line):
        def replace_match(match):
            text = match.group(0)
            # 检查是否为中英文双引号包裹的内容
            if (text.startswith('“') and text.endswith('”')) or (text.startswith('"') and text.endswith('"')):
                return text
            else:
                return text.replace(old_word, new_word)
        # 匹配中英文双引号内的内容或非引号内容
        return re.sub(r'“[^”]*”|"[^"]*"|[^“”"]+', replace_match, line)
    
    return [replace_line(line) for line in lines]