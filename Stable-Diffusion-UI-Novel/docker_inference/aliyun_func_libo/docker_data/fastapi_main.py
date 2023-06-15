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
    await asyncio.sleep(10) # 110秒够启动sd了
    # 返回html---不断重复请求当前api----直到sdwebui启动成功
    return HTMLResponse(content="""
    <html>

    <head>
        <title>Starting sd ....</title>
        <script type="text/javascript">
            // 当页面加载完成后执行
            window.onload = function () {
                console.log(2222222)
                var countdown = 3; // 倒计时的初始值
                // 创建一个定时器，每秒减少倒计时值
                var timer = setInterval(function () {
                    countdown--;
                    document.getElementsByTagName('h1')[0].innerHTML = "200，请耐心等待 sdwebui 服务器启动（大约 2-4 分钟）... 倒计时 " + countdown + " 秒，自动刷新浏览器";

                    // 当倒计时为0时，清除定时器并刷新页面
                    if (countdown == 0) {
                        clearInterval(timer);
                        window.location.href = window.location.href;
                    }
                }, 1000);
            }
        </script>
    </head>

    <body>
        <h1>200，请耐心等待 sdwebui 服务器启动（大约 2-4 分钟）... 倒计时 3 秒，自动刷新浏览器</h1>
    </body>

    </html>
    """, status_code=200)

@app.get("/getlog")
async def getlog(filename: str=None, count: int=200):
    """
    获取日志
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


# sleep 1 &&  /share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -u -m uvicorn fastapi_main:app --port 9966








    
