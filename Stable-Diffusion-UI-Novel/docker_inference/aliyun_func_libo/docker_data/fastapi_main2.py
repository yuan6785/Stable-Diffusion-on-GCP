# coding=utf-8
from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
import os
import asyncio

global_is_startup = False


class YxFastAPI(FastAPI):
    """
    """
    async def __call__(self, scope, receive, send):
        """
        重写 __call__函数
        """
        if scope['type'] == 'lifespan':  # 生命周期判断，重要
            global global_is_startup  # 这里必须加global
            print(global_is_startup)
            if not global_is_startup:
                loop = asyncio.get_running_loop()
                # 启动全局startup的hook，在这个hook里面启动服务列表，可以单独用一个uvicorn.run来跑
                loop.create_task(uvicorn_start_up())
        await super().__call__(scope, receive, send)


app = YxFastAPI()


async def uvicorn_start_up():
    """
    """
    global global_is_startup   
    global_is_startup = True
    print("real app start1 ...")
    """
    需要启动的服务列表
    """
    await asyncio.sleep(2)
    print("real app start2 ...")
    nginx_start_info = os.system("/usr/sbin/nginx -c /etc/nginx/nginx.conf")
    print(f"nginx start info: {nginx_start_info}")

    


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
    await asyncio.sleep(10)  # 110秒够启动sd了
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

# sleep 1 &&  /share/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python -u -m uvicorn fastapi_main:app --port 9966
