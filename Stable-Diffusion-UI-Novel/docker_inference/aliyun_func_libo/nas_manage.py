# coding=utf-8
"""
nas管理
1.定期清理nas的outputs文件夹
2.定期清理lora里面的乱码文件名

/mnt/sdwebui_public/versions/sdwebui_env/miniconda3/envs/sd_python310/bin/python  nas_manage.py
"""

"""
pyenv activate py3.9_virtualenv_test
pip install uvloop==0.14.0 0.17.0
pip install uvicorn==0.13.0 0.22.0
pip install fastapi==0.63.0 0.98.0
pip install apscheduler==3.8.1 3.10.1
"""


import uvicorn
from fastapi import Depends, FastAPI
import os
import pytz
import pathlib
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from fastapi.responses import HTMLResponse
from apscheduler.triggers.cron import CronTrigger
import asyncio
import arrow
import shutil
app = FastAPI()


sched = AsyncIOScheduler()  #
display_zone = "Asia/Shanghai"


async def clean_nas_outputs(dur=8):
    """
    @des: 清理nas的outputs文件夹
    """
    try:
        print("清理nas的outputs文件夹")
        outputs_path = "/mnt/sdwebui_public/public/outputs"
        # 使用pathlib查找日期文件夹
        subobjs = list(pathlib.Path(outputs_path).rglob("20*"))
        subfolders = [subobj for subobj in subobjs if subobj.is_dir() == True]
        # print(111111, len(subfolers))
        # 找出日期文件夹名称小于当前日期的前7天的文件夹
        end_date = arrow.utcnow().shift(days=-dur).to(display_zone).format("YYYY-MM-DD")
        results = []
        for subfolder in subfolders:
            # 判断subfoler.name是否是日期格式
            try:
                valid_name = arrow.get(
                    subfolder.name, "YYYY-MM-DD").format("YYYY-MM-DD")
            except:
                valid_name = None
            if valid_name:
                if subfolder.name <= end_date:
                    print("删除文件夹: ", subfolder)
                    # shutil.rmtree(str(subfolder), ignore_errors=True)
                    results.append(str(subfolder))
        return results
    except Exception as e:
        print("clean_nas_outputs error: ", e)
        return []


async def add_aps_tasks():
    """
    @des: 执行定时任务的接口
    """
    # sched.add_job(clean_nas_outputs, 'cron', second="1", minute="46",
    #               hour="15", day_of_week="0-6", timezone=pytz.timezone(display_zone),
    #               id="api_server_loop")
    sched.add_job(clean_nas_outputs, CronTrigger.from_crontab('51 15 * * *'), timezone=pytz.timezone(display_zone),
                  id="api_server_loop")
    sched.start()


@app.on_event("startup")
async def startup_event():
    print("fastapi app start ...")
    asyncio.ensure_future(add_aps_tasks())


@app.get("/test/")
async def test():
    return 'test'


@app.get("/clean_outputs/", response_class=HTMLResponse)
async def clean_outputs(dur: int = 8):
    if dur < 8:  # 防止误操作
        dur = 8
    results = await clean_nas_outputs(dur)
    # 将results根据最后的日期排序
    results = sorted(results, key=lambda x: x.split("/")[-1], reverse=True)
    # results是一个json
    # return results
    # 将results拼接成html返回
    html = ""
    for result in results:
        html += result + "<br>"
    return html

if __name__ == '__main__':
    if 1:
        uvicorn.run(
            app='nas_manage:app',
            host="0.0.0.0",
            port=9006,
            reload=False,
            # 可以指定你想要用的异步库，也可以不用loop这个字段，用默认的asgi库,  [auto|asyncio|uvloop|iocp]
            # loop='uvloop'
        )
