"""FastAPI 应用入口"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import text_processing, file_operations

app = FastAPI(
    title="文本编辑器 API",
    version="0.1.0",
    description="Text-Edit-Read 后端服务，提供文本处理和文件操作 API",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(text_processing.router, prefix="/api/text", tags=["文本处理"])
app.include_router(file_operations.router, prefix="/api/file", tags=["文件操作"])


@app.get("/api/health")
async def health_check():
    return {"status": "ok"}
