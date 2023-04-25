"""
根据sd基础模型
生成sd基础模型的yaml工程
每个sd基础模型对应一个yaml工程，对应一个k8s文件夹，对应一个deployment，有自己的公网访问ip
"""
import os
import yaml


class GenTemplateDir(object):

    def __init__(
            self,
            k8s_subdir_name,
            sd_base_model_name
    ):
        """
        :param k8s_subdir_name: 保存模型的yaml文件夹名
        :param sd_base_model_name: sd基础模型名
        """
        self.k8s_subdir_name = k8s_subdir_name
        self.sd_base_model_name = sd_base_model_name
        #

    def make_deployment_yaml(self):
        """
        生成deployment.yaml文件
        """
        file_path = "./0_public_templates/deployment.yaml"
        with open(file_path, "r") as f:
            content = f.read()
            content = content % {"sd_base_model_name": self.sd_base_model_name}
        with open(self.k8s_subdir_name + "/deployment.yaml", "w") as f:
            f.write(content)

    def make_hpa_yaml(self):
        """
        生成deployment.yaml文件
        """
        file_path = "./0_public_templates/hpa.yaml"
        with open(file_path, "r") as f:
            content = f.read()
            content = content % {"sd_base_model_name": self.sd_base_model_name}
        with open(self.k8s_subdir_name + "/hpa.yaml", "w") as f:
            f.write(content)

    def make_service_multi_yaml(self):
        """
        生成service.yaml和ingress文件
        """
        file_path = "./0_public_templates/service_inference_multi.yaml"
        with open(file_path, "r") as f:
            content = f.read()
            content = content % {"sd_base_model_name": self.sd_base_model_name}
        with open(self.k8s_subdir_name + "/service_inference_multi.yaml", "w") as f:
            f.write(content)

    def make_service_signle_yaml(self):
        """
        生成service.yaml和ingress文件
        """
        file_path = "./0_public_templates/service_inference.yaml"
        with open(file_path, "r") as f:
            content = f.read()
            content = content % {"sd_base_model_name": self.sd_base_model_name}
        with open(self.k8s_subdir_name + "/service_inference.yaml", "w") as f:
            f.write(content)

    def make_cmds_txt(self):
        """
        生成service.yaml和ingress文件
        """
        file_path = "./0_public_templates/cmds.txt"
        with open(file_path, "r") as f:
            content = f.read()
            content = content % {
                "sd_base_model_name": self.sd_base_model_name, "k8s_subdir_name": self.k8s_subdir_name}
        with open(self.k8s_subdir_name + "/cmds.txt", "w") as f:
            f.write(content)

    def make_model_k8s_folder(self):
        """
        生成保存模型的yaml文件夹,并生成yaml文件
        """
        if not os.path.exists(self.k8s_subdir_name):
            os.makedirs(self.k8s_subdir_name)
            return True
        else:
            return False

    # def make_model_public_ingress(self):
    #     """
    #     修改sd_public_ingress.yaml文件
    #     """
    #     file_path = "./sd_public_ingress.yaml"
    #     # 使用yaml读取文件
    #     with open(file_path, "r") as f:
    #         content = yaml.load(f, Loader=yaml.FullLoader)
    #     # 查找
    #     for i in range(len(content["spec"]["rules"])):
    #         if content["spec"]["rules"][i]["host"] == self.sd_base_model_name + ".sd.com":
    #             print("ingress已存在,不再生成")
    #             return
    #     # 添加
    #     content["spec"]["rules"].append({
    #         "host": self.sd_base_model_name + ".sd.com",
    #         "http": {
    #             "paths": [
    #                 {
    #                     "path": "/",
    #                     'pathType': 'Prefix',
    #                     'backend': {
    #                         'service': {
    #                             'name': f'sd-service-{self.sd_base_model_name}', 
    #                             'port': {'number': 8080}
    #                         }
    #                     }
    #                 }
    #             ]
    #         }
    #     })
    #     # 写入
    #     with open(file_path, "w") as f:
    #         yaml.dump(content, f, default_flow_style=False)
        

    def make_all(self):
        """
        生成所有文件
        """
        if not self.make_model_k8s_folder():
            print("文件夹已存在,不再生成")
        else:
            self.make_deployment_yaml()
            self.make_hpa_yaml()
            self.make_service_multi_yaml()
            self.make_service_signle_yaml()  # 这个不用, 生成出来仅供参考
            self.make_cmds_txt()
            # self.make_model_public_ingress()


if __name__ == "__main__":
    folder_infos = [
        # {
        #     "k8s_subdir_name": "yuanxiao_test_folder",
        #     "sd_base_model_name": "yxtestmodel"
        # },
        {
            "k8s_subdir_name": "sd-v15",
            "sd_base_model_name": "sd15"
        },
        {
            "k8s_subdir_name": "dreamworld_v30",
            "sd_base_model_name": "dreamworld"
        },
        {
            "k8s_subdir_name": "haha",
            "sd_base_model_name": "haha"
        },
    ]
    #
    for folder_info in folder_infos:
        gen_template_dir = GenTemplateDir(
            k8s_subdir_name=folder_info["k8s_subdir_name"],
            sd_base_model_name=folder_info["sd_base_model_name"]
        )
        gen_template_dir.make_all()
