文件管理系统
可挂载nfs进行管理


文档
https://hub.docker.com/r/bitnami/minio

helm文档
https://github.com/bitnami/charts/tree/main/bitnami/minio

更新资源
helm repo add bitnami https://charts.bitnami.com/bitnami
helm update 
查看所有版本
helm search repo bitnami/minio --versions 
安装
# persistence.size 是一个可选参数，用于指定 MinIO 存储的容量。如果未指定，MinIO 将使用默认的存储大小
# vol1 是一个已经存在的 PVC 名称，用于存储 MinIO 数据。如果未指定，MinIO 将使用默认的存储类
helm install my-release bitnami/minio --version 12.4.1 \
  --set persistence.enabled=true \
  --set persistence.storageClass="" \
  --set persistence.existingClaim=vol1 \
  --set persistence.mountPath=/export \
  --set imagePullPolicy=Always

# 加入本地到service的端口映射，即service是clusterIP，不对外暴露，但是可以通过端口映射访问
# 执行下面的命令访问 localhost:9001即可， 太牛了
kubectl port-forward --namespace default svc/my-release-minio 9001:9001 

运行客户端命令:
    获取用户名和密码
        kubectl get secret --namespace default my-release-minio -o jsonpath="{.data.root-user}" | base64 -d
        kubectl get secret --namespace default my-release-minio -o jsonpath="{.data.root-password}" | base64 -d
        -----
        admin
        q9NXUnneDu

    # 加入用户信息
    kubectl run --namespace default my-release-minio-client \
    --rm --tty -i --restart='Never' \
    --env MINIO_SERVER_ROOT_USER=上面的用户名 \
    --env MINIO_SERVER_ROOT_PASSWORD=上面的密码 \
    --env MINIO_SERVER_HOST=my-release-minio \
    --image docker.io/bitnami/minio-client:2023.4.12-debian-11-r3 -- admin info minio




卸载
helm delete my-release
