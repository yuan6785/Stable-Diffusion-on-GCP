# coding=utf-8
import json
import copy
import pprint
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
        project_admin_file = "./project_admin.txt"
        with open (project_admin_file, "r") as f:
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
                new_project_admin["Statement"][1]['Condition']['StringLike']['s3:prefix'].insert(0, ox)
                new_project_admin["Statement"][2]['Resource'].insert(0, op)
            policies[admin_email] = new_project_admin
            pprint.pprint(policies)
            break 


if __name__=="__main__":
    mp = MakePolicy()
    mp.make_project_admin()
