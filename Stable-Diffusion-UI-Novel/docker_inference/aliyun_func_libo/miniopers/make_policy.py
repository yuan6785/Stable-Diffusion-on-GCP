# coding=utf-8
import json
import copy
import pprint
import os


class MakePolicy(object):
    def __init__(self):
        self.project_admin_config = [
            ["陈敏", "chenmin@playdayy.com", ["Resort", "Zoo"]],
            ["李海", "lihai@playdayy.com", ["Cooking"]],
            ["赵子龙", "zhaozilong@playdayy.com", ["Lucky"]],
            ["李泳钢", "liyonggang@playdayy.com", ["Dog"]],
            ["赵藜莉", "zhaolili@playdayy.com", ["Dragon", "Butterfly"]],
            ["吕珊珊", "senna@playdayy.com", ["chanxuan"]],
            ["李雪", "lixue@playdayy.com", ["Ui_beijing"]],
            ["吕星", "lvxing@playdayy.com", ["2D_chengdu"]],
            ["张晨睿", "zhangchenrui@playdayy.com", ["3D_beijing"]],
            ["段毅", "duanyi@playdayy.com", ["3D_chengdu"]],
            ["韩龙宇", "hanlongyu@playdayy.com", ["Effect"]],
        ]

    def make_project_admin(self):
        """
        动态生成策略文件并写入minio
        """
        project_admin_file = "./project_admin.txt"  # 项目管理员权限模板文件
        with open(project_admin_file, "r") as f:
            project_admin = f.read()
            project_admin = json.loads(project_admin)
        policies = {}
        for project_admin_item in self.project_admin_config:
            new_project_admin = copy.deepcopy(project_admin)
            admin_email = project_admin_item[1]
            lora_project_names = project_admin_item[2]
            for lora_project_name in lora_project_names:
                ox = f"Lora/{lora_project_name}/*"
                op = f"arn:aws:s3:::models/Lora/{lora_project_name}/*"
                new_project_admin["Statement"][1]['Condition']['StringLike']['s3:prefix'].insert(
                    0, ox)
                new_project_admin["Statement"][2]['Resource'].insert(0, op)
            policies[admin_email] = new_project_admin
            # pprint.pprint(policies)
        for admin_email, policy in policies.items():
            with open(f"./tmppolicys/{admin_email}.txt", "w") as f:
                f.write(json.dumps(policy, indent=4))
            os.system(
                f"./mc.RELEASE.2022-06-10T22-29-12Z admin policy add myminio {admin_email} ./tmppolicys/{admin_email}.txt")
            os.system(f"rm -rf ./tmppolicys/{admin_email}.txt")

# 下面两条都是在本地生成配置文件 普通客户端和admin客户端都用这种方式认证（ACCESS_KEY和SECRET_KEY可以在web页面获取，hostname是必须--address的地址和端口，不是--console-address;
# 例如启动命令是 command=bash -c "sleep 10 &&  minio server  --anonymous --address 0.0.0.0:9001 --console-address 0.0.0.0:9002 /mnt/sdwebui_public/public"
# 那么hostname就是 http://xxxxxxx:9001, 不是9002
# 本笔记搜索【minio登录命令】---我的启动实际命令
# ./mc.RELEASE.2022-06-10T22-29-12Z config host add minio http://myhost.com "ACCESS_KEY" "SECRET_KEY"
# ./mc.RELEASE.2022-06-10T22-29-12Z alias set myminio http://myhost.com ACCESS_KEY SECRET KEY

# 用上面的命令登录后， 就可以自由使用其他命令, 测试命令
# ./mc.RELEASE.2022-06-10T22-29-12Z admin policy ls myminio

# 生成配置文件---多次执行如果存在会更新
# ./mc.RELEASE.2022-06-10T22-29-12Z admin policy add myminio hahahaha ./project_admin.txt


if __name__ == "__main__":
    mp = MakePolicy()
    mp.make_project_admin()
