用anconda版本的dockerfile
记得修改deployment.yaml中的挂载位置

最终用的是
Dockerfile.finally.yx  ------  (就一个docker文件，入口命令就是sdwebui，简单，方便维护, 出问题直接重启出问题的pod)----可能需要循环遍历pod的日志，看看有没有报错 

但是:

Dockerfile.root.ancondapython.yx ------ 超级重要(虽然没有在线上用，但是后期优化可以优先选择这个)，有循环任务，sdwebui放到supervisor,没有nginx代理，害怕出奇怪问题(后期优化可以优先使用这个)

Dockerfile.root.ancondapython.nginx.supervisor.yx ----超级重要(虽然没有在线上用)----非常有参考价值，有nginx代理sdwebui，supervisor管理多个进程，循环任务等等

