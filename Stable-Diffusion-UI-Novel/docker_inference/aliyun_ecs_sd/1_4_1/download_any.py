"""
gradio==3.35.2  
fastapi==0.95.2
@des: 
服务器批量下载文件，带进度条显示
在什么文件夹启动这个脚本，就会在这个文件夹下进行下载内容
参考: 0yxgithub/userful_scripts/gradio_test/test_download_file_server_progress_fastapi_one.py
"""
import gradio as gr
import requests
from tqdm import tqdm

#
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, FileResponse
from jinja2 import Template
from fastapi.templating import Jinja2Templates
import os
import gradio as gr
import time
import pathlib
import asyncio
import pandas as pd

# 线程池
from concurrent.futures import ThreadPoolExecutor

"""
公共定义部分
"""

download_executor = ThreadPoolExecutor(max_workers=1)

yx_process = []


def has_symlink_in_path(path, is_all=True):
    """
    @des: 判断path中是否存在软链接
    """
    path = pathlib.Path(path)
    if path.is_symlink():
        return True
    # 是否判断所有父目录
    if is_all:
        for p in path.parents:
            if p.is_symlink():
                return True
    return False


"""
gradio部分
"""


def download_file_i(download_info):
    """
    @des:
    """
    server_path = download_info[0]
    url = download_info[1]
    #
    try:
        #
        download_info[2] = "开始下载"
        #
        response = requests.get(url, stream=True, timeout=(5, 7200))
        total_size = int(response.headers.get("content-length", 0))
        #
        # 提取文件名
        # file_name = url.split("/")[-1]
        # file_path = f"{server_path}/{file_name}"
        # 提取server_path的父目录
        server_path_parent = pathlib.Path(server_path).parent
        if not server_path_parent.exists():
            server_path_parent.mkdir(parents=True)
        file_name = pathlib.Path(server_path).name
        #
        # 使用 tqdm 显示下载进度
        with open(server_path, "wb") as file, tqdm(  # 这个tqdm在后端显示进度条
            desc=file_name,
            total=total_size,
            unit="B",
            unit_scale=True,
            unit_divisor=1024,
            # bar_format='{desc}：{percentage:3.0f}%|{bar}|{n_fmt}/{total_fmt} [{elapsed}<{remaining}]'
        ) as bar:
            downloaded_size = 0
            for data in response.iter_content(chunk_size=1024):
                file.write(data)
                bar.update(len(data))
                downloaded_size += len(data)
                _i = (downloaded_size / total_size) * 100
                process_i = f"{_i:.2f}%  --  ({downloaded_size/1024/1024:.2f}MB / {total_size/1024/1024:.2f}MB)"
                download_info[2] = process_i

        return f"文件已下载到服务器路径: {server_path}"
    except Exception as e:
        download_info[2] = f"发生错误：{str(e)}"
        return f"发生错误：{str(e)}"


def download_files(download_content):
    """
    @des: 判断输入部分是否正确，如果正确则下载，否则提示错误
    """
    try:
        msg = ""
        global yx_process
        download_content = download_content.strip()
        if not download_content:
            msg = "请输入下载资源内容"
            raise Exception(msg)
        # 正则替换中文逗号
        download_content = download_content.replace("，", ",")
        # 按照换行符分割
        download_content = download_content.split("\n")
        #
        for item in download_content:
            items = item.split(",")
            if len(items) != 2:
                msg = "资源格式错误，应为：保存路径,下载链接"
                raise Exception(msg)
            server_path, url = items[0], items[1]
            server_path = server_path.strip()
            # # 判断server_path是否有权限
            # server_path_i = pathlib.Path(server_path)
            # # 绝对路径
            # server_path_i = server_path_i.absolute()
            # print(11111, server_path_i)
            # raise
            if server_path[0] == "/":
                msg = "server_path不能以/开头"
                raise Exception(msg)
            if server_path.find("..") != -1:
                msg = "server_path不能包含.."
                raise Exception(msg)
            # 判断是否是文件夹
            if os.path.isdir(server_path):
                msg = "server_path不能是已经存在的文件夹"
                raise Exception(msg)
            # 判断server_path中是否存在软链接
            if has_symlink_in_path(server_path):
                msg = "server_path中不能包含软链接"
                raise Exception(msg)
            url = url.strip()
            # 保存到全局变量
            yx_process.append([server_path, url, "未开始"])

        # 下载
        # for item in yx_process:
        #     download_file_i(item)
        # 使用线程池
        for item in yx_process:
            if item[2] == "未开始":
                download_executor.submit(download_file_i, item)
    except:
        pass
    # time.sleep(10)
    if msg:
        return f"""<p style='color:red'>{msg}</p>"""
    else:
        return msg


def pd_clear(info_o1, info_i1):
    """
    @des: 判断是否清理输入下载框，如果下载成功则清理，如果出错了则不清理
    """
    # print(1111, info)
    if info_o1 == "":  # 下载成功
        return None  # 清理
    else:
        return info_i1  # 不清理


tiaozhuan_js = """
    async function(){
        document.getElementById("yxpro").innerHTML = "下载进度显示"
        // 循环请求/progess接口，获取进度
        while(1){
            let res = await fetch("/progress")
            let text = await res.text()
            document.getElementById("yxpro").innerHTML = text
            await new Promise(resolve => setTimeout(resolve, 1000))
        }
    }
"""

with gr.Blocks() as demo:
    # with gr.Row(visible=True):
    i1_help = gr.HTML(
        """<div id="xxfdsa">
        资源格式: 保存路径,下载链接<br/>
        注意保存路径不要以/开始, 多条以换行分隔即可<br/>
        例如: <br/>
        <p style="color:gray">
            models/diffusion_pytorch_model.bin, https://huggingface.co/stabilityai/sdxl-vae/resolve/main/diffusion_pytorch_model.bin  <br/>
            models/diffusion_pytorch_model2.bin, https://huggingface.co/stabilityai/sdxl-vae/resolve/main/diffusion_pytorch_model.bin 
        </p>
        </div>"""
    )
    i1 = gr.Textbox(
        label="输入下载资源内容",
        default="",
        lines=5,
        max_lines=5,
        autoscroll=False,
        show_copy_button=True,
        placeholder="保存路径,下载链接",
        # info="""
        # 请在此处输入下载资源的URL，
        # 每行一个资源信息格式为:
        # """
    )

    # 输出错误信息的控件，不用输入
    o1 = gr.HTML("""""")
    #
    html = gr.HTML("""<div id="yxpro"></div>""")
    #
    btn = gr.Button(value="开始下载")
    # btn = gr.ClearButton(value="开始下载", components=[i1])
    btn.click(
        fn=download_files, inputs=[i1], outputs=[o1]
    ).then(  # 下载成功后清理输入框
        pd_clear, inputs=[o1, i1], outputs=[i1], queue=False
    )
    # btn.click(fn=lambda x: None, inputs=None, outputs=[i1], queue=False)  # 和上面的then效果一样，但是then可以保证比click后执行
    #
    demo.load(fn=None, inputs=[], outputs=[], _js=tiaozhuan_js)  # 直接跳转到下载页面
    #
    demo.queue(concurrency_count=3)  # 支持进度条显示


"""
fastapi的支持
"""

app, local_url, share_url = demo.launch(
    share=False,  # 如果一直得到到公共连接，并由此而卡住，可以设置为False
    prevent_thread_lock=True,  # 非阻塞方式运行gradio,最后用while 1: time.sleep(0.5)来阻塞即可
    server_name="0.0.0.0",
    server_port = 9005,
    # root_path='/haha',  # 指定一个路径，否则会默认为根路径，根路径另外有用，下面的fastapi的api需要用到;---目前会报错 theme.css文件找不到，所以用上面的tiaozhuan_js先绕过去
    # allowed_paths=["/haha"],  # 指定一个路径，否则会默认为根路径，根路径另外有用，下面的fastapi的api需要用到
    # inbrowser=True,
)


@app.get("/progress", response_class=HTMLResponse)
async def progress(request: Request):
    """ """
    global yx_process
    # 生成html--table
    if yx_process:
        table_html = "下载进度显示:<br/><table>"
         # 倒序取10个
        for item in yx_process[-10:][::-1]:
            table_html += f"<tr><td>{item[0]}</td><td>{item[2]}</td></tr>"
        table_html += "</table>"
    else:
        table_html = ""
    response = HTMLResponse(table_html)
    # 解决跨域问题，js中的fetch请求会被拦截
    # response.headers["x-content-type-options"] = "nosniff"
    return response



async def main():
    # 启动函数
    # asyncio.ensure_future(write_to_log_file())
    # end 启动函数
    while 1:
        await asyncio.sleep(0.5)


if __name__ == "__main__":
    if 0:
        loop = asyncio.get_event_loop()
        asyncio.ensure_future(main())
        loop.run_forever()
    else:
        # asyncio.ensure_future(main())
        asyncio.run(main())
