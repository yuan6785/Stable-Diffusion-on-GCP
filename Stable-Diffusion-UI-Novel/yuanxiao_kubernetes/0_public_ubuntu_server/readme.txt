vsftpd的虚拟用户配置参考笔记【vsftp配置虚拟用户访问】

https://blog.csdn.net/weixin_45444133/article/details/119203342  参考这个k8s部署



您可以通过以下步骤在 GKE 上创建 Service 和 Ingress 来公开 vsftpd：

    创建一个 Kubernetes Service，该服务将暴露 vsftpd Pod 的端口。可以使用以下 YAML 文件创建一个 Service：

yaml

apiVersion: v1
kind: Service
metadata:
  name: vsftpd-service
spec:
  selector:
    app: vsftpd
  ports:
    - name: ftp
      protocol: TCP
      port: 21
      targetPort: 21
    - name: passive-ports
      protocol: TCP
      port: 20000-20045
      targetPort: 20000-20045
  type: ClusterIP

    创建一个 Kubernetes Ingress，该 Ingress 将将外部流量路由到该 Service。可以使用以下 YAML 文件创建一个 Ingress：

yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vsftpd-ingress
spec:
  rules:
    - host: vsftpd.example.com # 将此值更改为您的域名
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: vsftpd-service
                port:
                  name: ftp

    部署和启动 Service 和 Ingress：

ruby

$ kubectl apply -f vsftpd-service.yaml
$ kubectl apply -f vsftpd-ingress.yaml

这将创建一个 Service 和 Ingress，以公开 vsftpd Pod 的端口。在 Ingress 创建后，您需要将 vsftpd.example.com 添加到您的 DNS 服务器中，并使用 ftp://vsftpd.example.com 连接到 vsftpd 服务器。