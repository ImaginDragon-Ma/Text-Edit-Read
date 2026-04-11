"""文本处理 API"""
from fastapi import APIRouter, HTTPException

from app.services.text_processor import TextProcessor, TextProcessingError
from app.models.schemas import (
    CleanTextRequest, CleanTextResponse,
    FindTextRequest, FindTextResponse,
    ReplaceAllRequest, ReplaceAllResponse,
    ReplaceExceptQuotesRequest, ReplaceExceptQuotesResponse,
)

router = APIRouter()


@router.post("/clean", response_model=CleanTextResponse)
async def clean_text(req: CleanTextRequest):
    """清理文本：去空行、章节标题独立、段落缩进"""
    try:
        cleaned = TextProcessor.clean_text(req.text)
        return CleanTextResponse(cleaned_text=cleaned)
    except TextProcessingError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/find", response_model=FindTextResponse)
async def find_text(req: FindTextRequest):
    """查找文本中的目标词"""
    try:
        position, matched = TextProcessor.find_text(
            req.text, req.search_term, req.start_pos, req.direction
        )
        return FindTextResponse(position=position, matched_text=matched)
    except TextProcessingError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/replace-all", response_model=ReplaceAllResponse)
async def replace_all(req: ReplaceAllRequest):
    """替换所有匹配的词"""
    try:
        lines, count = TextProcessor.replace_all_word(req.lines, req.old_word, req.new_word)
        return ReplaceAllResponse(lines=lines, replace_count=count)
    except TextProcessingError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/replace-except-quotes", response_model=ReplaceExceptQuotesResponse)
async def replace_except_quotes(req: ReplaceExceptQuotesRequest):
    """替换双引号外的指定单词"""
    try:
        lines, count = TextProcessor.replace_except_in_quotes(req.lines, req.old_word, req.new_word)
        return ReplaceExceptQuotesResponse(lines=lines, replace_count=count)
    except TextProcessingError as e:
        raise HTTPException(status_code=400, detail=str(e))
