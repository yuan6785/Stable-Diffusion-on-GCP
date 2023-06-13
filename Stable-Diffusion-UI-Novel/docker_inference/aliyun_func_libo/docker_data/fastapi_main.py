# coding=utf-8
from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
import os
import asyncio
app = FastAPI()


@app.get("/")
async def root():
    await asyncio.sleep(120) # 120秒够启动sd了
    # 返回html
    return HTMLResponse(content="""
    <html>
        <head>
            <title>starting sd ....</title>
        </head>
        <body>
            <h1>200,请耐心等待sdwebui服务器启动(大概2-4分钟)...</h1>
        </body>
    </html>
    """, status_code=200)

# sleep 1 &&  /share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -u -m uvicorn fastapi_main:app --port 9966








    
