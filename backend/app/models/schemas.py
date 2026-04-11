"""Pydantic 请求/响应模型"""
from pydantic import BaseModel, Field
from typing import Optional


# === 文本处理 ===

class CleanTextRequest(BaseModel):
    text: str = Field(..., description="要清理的文本")


class CleanTextResponse(BaseModel):
    cleaned_text: str


class FindTextRequest(BaseModel):
    text: str = Field(..., description="要查找的文本")
    search_term: str = Field(..., description="查找目标词")
    start_pos: int = Field(0, ge=0, description="起始位置")
    direction: str = Field("next", pattern="^(next|previous)$", description="查找方向")


class FindTextResponse(BaseModel):
    position: Optional[int] = None
    matched_text: Optional[str] = None


class ReplaceAllRequest(BaseModel):
    lines: list[str] = Field(..., description="文本行列表")
    old_word: str = Field(..., description="要替换的旧词")
    new_word: str = Field(..., description="新词")


class ReplaceAllResponse(BaseModel):
    lines: list[str]
    replace_count: int


class ReplaceExceptQuotesRequest(BaseModel):
    lines: list[str] = Field(..., description="文本行列表")
    old_word: str = Field(..., description="要替换的旧词")
    new_word: str = Field(..., description="新词")


class ReplaceExceptQuotesResponse(BaseModel):
    lines: list[str]
    replace_count: int


# === 文件操作 ===

class ReadFileRequest(BaseModel):
    file_path: str = Field(..., description="文件路径")
    encoding: Optional[str] = Field(None, description="文件编码，None 则自动检测")


class ReadFileResponse(BaseModel):
    content: str
    encoding: str


class SaveFileRequest(BaseModel):
    file_path: str = Field(..., description="文件路径")
    content: str = Field(..., description="要保存的内容")
    encoding: str = Field("utf-8", description="保存编码")


class SaveFileResponse(BaseModel):
    message: str = "文件保存成功"


class DetectEncodingRequest(BaseModel):
    file_path: str = Field(..., description="文件路径")


class DetectEncodingResponse(BaseModel):
    encoding: str
