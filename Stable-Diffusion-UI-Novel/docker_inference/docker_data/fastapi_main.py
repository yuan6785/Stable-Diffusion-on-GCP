# coding=utf-8
from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
import os
import asyncio
app = FastAPI()


async def tail_file(file_path: str, websocket: WebSocket):
    with open(file_path, "r") as f:
        # Seek to the end of the file
        f.seek(0, os.SEEK_END)

        while True:
            line = f.readline()
            if line:
                await websocket.send_text(line)
            else:
                # Sleep for a short interval to avoid CPU hogging
                await asyncio.sleep(0.1)


@app.get("/wqipqniwalala/restart_server")
async def root():
    os.system("supervisorctl restart sdwebui")
    return {"message": "restart success"}


@app.get("/wqipqniwalala/sdwebuilogs")
# 从url读取get参数filename
async def get_file(filename: str=None, count: int=200):
    """
    http://34.27.19.204/wqipqniwalala/sdwebuilogs?filename=loopscript&count=100
    http://34.27.19.204/wqipqniwalala/sdwebuilogs?filename=sdwebui&count=100
    http://34.27.19.204/wqipqniwalala/sdwebuilogs?filename=fastapi_main&count=100
    """
    # 读取文件内容
    if filename is None:
        filepath = "/var/log/sdwebui.log"
    else:
        filepath = f"/var/log/{filename}.log"
    # 读取最后count行,html 换行格式化返回
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            lines = f.readlines()
            lines = lines[-count:]
            lines = "<br/>".join(lines)
            return HTMLResponse(content=lines)
    else:
        return {"message": "file not exist"}




    
