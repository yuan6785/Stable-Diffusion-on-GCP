用anconda版本的dockerfile
记得修改deployment.yaml中的挂载位置

最终用的是
Dockerfile.root.ancondapython

但是:
Dockerfile.root.ancondapython.supervisor 也非常重要----非常有参考价值，有nginx代理sdwebui，supervisor管理多个进程，循环任务等等