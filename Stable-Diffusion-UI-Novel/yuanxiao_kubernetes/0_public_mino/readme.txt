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
# 参数参考 https://github.com/bitnami/charts/tree/main/bitnami/minio#parameters
# 重要: vol1需要用ubuntu镜像挂载进去，修改根目录权限为777, 否则会报权限错误------------非常重要-----
# kubectl  exec -it   -n default $(kubectl get pods  -n default  |grep ubuntu |awk '{print $1}' |awk NR==1)   /bin/bash
# 例如: chmod -Rf 777 yuanxiao_root_nfs/  # 注，原来是777
# 但是别用--set volumePermissions.enabled=true, 虽然也生效，但是会影响其他的pod使用vol1这个pv, 因为把目录权限修改了, 会修改为1001:1001
# 例如: drwxr-xr-x   5 1001 1001 4.0K Apr 27 10:02 yuanxiao_root_nfs
# 上面的vol权限不改, 修改provisioning.containerSecurityContext.runAsNonRoot和containerSecurityContext.runAsNonRoot为false测试也不行，还是得改vol的权限为777
helm install my-release bitnami/minio --version 12.4.1 \
  --set persistence.enabled=true \
  --set persistence.storageClass="nfs" \
  --set persistence.accessModes=["ReadWriteMany"] \
  --set persistence.existingClaim=vol1 \
  --set persistence.mountPath=/data \
  --set imagePullPolicy=Always \
  --set provisioning.containerSecurityContext.runAsNonRoot=false \
  --set containerSecurityContext.runAsNonRoot=false \
  --set ingress.enabled=true \
  --set ingress.hostname=web.minio.localhost \
  --set apiIngress.enabled=true \
  --set apiIngress.hostname=api.minio.localhost

自己创建ingress
kubectl apply -f ingress.yaml

# 通过ingress访问
https://docs.bitnami.com/kubernetes/infrastructure/minio/configuration/configure-ingress/
# 加入本地到service的端口映射，即service是clusterIP，不对外暴露，但是可以通过端口映射访问
# 执行下面的命令访问 localhost:9001即可， 太牛了-----但总超时
kubectl port-forward --namespace default svc/my-release-minio 9001:9001 

运行客户端命令(测试用---实际并没啥用----):
    获取用户名和密码
        kubectl get secret --namespace default my-release-minio -o jsonpath="{.data.root-user}" | base64 -d
        kubectl get secret --namespace default my-release-minio -o jsonpath="{.data.root-password}" | base64 -d
        -----
        admin
        OiJbYoeJnI

    # 加入用户信息
    kubectl run --namespace default my-release-minio-client \
    --rm --tty -i --restart='Never' \
    --env MINIO_SERVER_ROOT_USER=上面的用户名 \
    --env MINIO_SERVER_ROOT_PASSWORD=上面的密码 \
    --env MINIO_SERVER_HOST=my-release-minio \
    --image docker.io/bitnami/minio-client:2023.4.12-debian-11-r3 -- admin info minio




卸载
helm delete my-release
kubectl delete ingerss sd-minio-ingress
kubectl delete configmap sd-minio-backendconfig