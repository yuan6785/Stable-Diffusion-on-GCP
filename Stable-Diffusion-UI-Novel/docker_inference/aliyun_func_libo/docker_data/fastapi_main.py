# coding=utf-8
from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
import os
import asyncio
app = FastAPI()


@app.get("/")
async def root():
    """
    @des: 
    重要文件，解决sdwebui放在后端或者supervisor里面启动不了的问题；
    当云函数启动后，只有在访问云函数期间，cpu才不会被冻结，所以这里的做法是云函数启动后
    访问根url，然后等待120秒(这期间cpu不会被冻结)，
    这样sdwebui就有足够的时间启动了，然后再返回html，这样就可以

    云函数并发度设置为： 500
    """
    await asyncio.sleep(120) # 120秒够启动sd了
    # 返回html
    return HTMLResponse(content="""
    <html>
        <head>
            <title>starting sd ....</title>
        </head>
        <body>
            <h1>200,请耐心等待sdwebui服务器启动(大概2-4分钟)...刷新浏览器</h1>
        </body>
    </html>
    """, status_code=200)

# sleep 1 &&  /share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -u -m uvicorn fastapi_main:app --port 9966








    
