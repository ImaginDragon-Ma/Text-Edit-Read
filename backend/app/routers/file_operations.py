"""文件操作 API"""
from fastapi import APIRouter, HTTPException
from pathlib import Path

from app.services.file_handler import FileHandler, FileOperationError, EncodingDetectionError
from app.models.schemas import (
    ReadFileRequest, ReadFileResponse,
    SaveFileRequest, SaveFileResponse,
    DetectEncodingRequest, DetectEncodingResponse,
)

router = APIRouter()


@router.post("/read", response_model=ReadFileResponse)
async def read_file(req: ReadFileRequest):
    """读取文件内容"""
    path = Path(req.file_path)
    try:
        content = FileHandler.read_file(path, req.encoding)
        encoding = req.encoding or FileHandler.detect_encoding(path)
        return ReadFileResponse(content=content, encoding=encoding)
    except FileOperationError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/save", response_model=SaveFileResponse)
async def save_file(req: SaveFileRequest):
    """保存文件内容"""
    path = Path(req.file_path)
    try:
        FileHandler.save_file(path, req.content, req.encoding)
        return SaveFileResponse()
    except FileOperationError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/detect-encoding", response_model=DetectEncodingResponse)
async def detect_encoding(req: DetectEncodingRequest):
    """检测文件编码"""
    path = Path(req.file_path)
    try:
        encoding = FileHandler.detect_encoding(path)
        return DetectEncodingResponse(encoding=encoding)
    except (FileOperationError, EncodingDetectionError) as e:
        raise HTTPException(status_code=400, detail=str(e))
