import os.path as path
import json as js
import os,sys
import argparse
import shutil
import time
from shortcut import *
pwd=path.dirname(path.abspath(__file__))+"/"
dataPwd="/etc/epha/"
cfgPwd=dataPwd+"/config/"
phyPwd=f"{dataPwd}/phy/"
nodePwd=f"{dataPwd}/node/"
wkPwd=f"{dataPwd}wk/"

def self_remove():
  pass

def self_update():
  shell="""
  cd /opt/fctok/EasyPhalaCluster/&&git pull
  chmod 777 /opt/fctok/EasyPhalaCluster/run.sh
  """
  os.system(shell)


def save_cfg():
    global cfgFile
    try:os.makedirs(cfgPwd)
    except:pass
    cfgFile=cfgPwd+"cfg.json"
    with open(cfgFile,"w+") as fw:
          js.dump(cfgs,fw)


def load_cfg():
    global cfgs
    if args.dbg!="off":print("dbg model is enabled")
    cfgFile=cfgPwd+"cfg.json"
    try:
        with open(cfgFile,"r+") as fr: cfgs=js.load(fr)
    except:
      cfgs=dict()
      cfgs['phyCnt']=0
      save_cfg()#create folder


def check_authority():
  shell=""" exit $UID """
  ret=os.system(shell)
  if ret!=0:
    print("Please run with sudo!")
    exit(0)

def docker_ins():
  shell=f"""
  apt install curl wget -y
  bash {pwd}/scripts/docker_ins.sh
  systemctl start docker
  """
  os.system(shell)
  
def sgx_check():
  shell=f"""
  {pwd}/tools/sgx_enable
  """
  ret=os.popen(shell)
  print(ret.read())
  return

def sgx_ins():
  shell=f"""
  bash {pwd}scripts/sgx_ins.sh
  """
  os.system(shell)

def node_ins():
  docker_ins()
  nodePwd=f"{pwd}/node/"
  if not os.path.exists(nodePwd):
    shutil.copytree(f"{pwd}tmpl/node", nodePwd)
  shell=f"""docker-compose -f {nodePwd}docker-compose.yml --env-file {nodePwd}/.env up -d"""
  os.system(shell)

def add_phy():
  global phyCnt
  # if not os.path.exists(nodePwd):
  #   print("请先完成主节点的安装");exit(0)
  try:os.makedirs(phyPwd)
  except:pass
  print("""注意:每个worker需要独立gas,
          通过重复输入一个桥名称，可以实现对之前worker信息的修改""")
  nickname=input("输入桥名称")
  gas_addr=input("请输入GAS账户地址:")
  gas_key=input("请输入GAS账户助记词:")
  own_addr=input("请输入持有者地址:")
  wkIp=input("输入worker的内网地址:(如果本机同时部署worker可输入[本机区域网地址])")
  nodeIp=input("输入nodeIp:(node机内网IP)")
  _phyPwd=phyPwd+nickname+"/"
  if os.path.exists(_phyPwd):
    input("确定修改？输入任意字符确定,CTRL+C取消")
    shutil.rmtree(_phyPwd)
  shutil.copytree(f"{pwd}/tmpl/pherry", _phyPwd)
  cfgs['phyCnt']+=1
  fa=open(f"{_phyPwd}/.env","a+")
  fa.write(f"MNEMONIC={gas_key}\n")
  fa.write(f"GAS_ACCOUNT_ADDRESS={gas_addr}\n")
  fa.write(f"OPERATOR={own_addr}\n")
  fa.write(f"WORKERIP={wkIp}\n")
  fa.write(f"NODEIP={nodeIp}\n")
  fa.close()
  shell=f"""docker-compose -f {_phyPwd}docker-compose.yml --env-file {_phyPwd}/.env up -d"""
  os.system(shell)

def node_remove():
  shell=f"""
     docker stop $(docker ps -q) & docker rm $(docker ps -aq) 1
     apt -y autoremove nodejs
     rm -rf {pwd}/phy
  """
  os.system(shell)
  print("已删除所有容器与worker连接信息")

def wk_ins():
  core=int(input("请输入用于计算的核心数:"))
  docker_ins()
  sgx_ins()
  if os.path.exists(wkPwd):
    print("2s后覆盖安装,CTRL+C取消")
    time.sleep(2)
    shutil.rmtree(wkPwd)
  shutil.copytree(f"{pwd}tmpl/wk", wkPwd)
  fa=open(f"{wkPwd}/.env","a+")
  if core<=0:exit(0)
  fa.write(f"CORES={core}")
  fa.close()
  shell=f"""
  docker-compose -f {wkPwd}docker-compose.yml --env-file {wkPwd}.env up -d
  echo "本机绑定的所有IP："
  ip a|grep inet
  """
  os.system(shell)

def wk_list():print("稍后开发")

def node_status():
  shell="""docker logs phala-node --tail=50"""
  os.system(shell)

def parse_args():
    parser = argparse.ArgumentParser(description="Phala主从模式部署easy脚本")
    parser.add_argument('-dbg',nargs="?", default='off', help='debug')
    parser.add_argument('-add',nargs="?", default='off', help='add shortcut')
    parsed_args = parser.parse_args()
    return parsed_args

if __name__ == "__main__": 
  args = parse_args()
  if args.add!="off": add_bashrc()
  check_authority()
  load_cfg()
  print("""
1.在本机安装主节点
2.在本机安装worker
3.主节点功能：关联worker到主节点
4.主节点功能：查看worker列表
5.主节点功能：查看主节点运行状态
6.主节点功能：卸载
7.检测SGX配置
8.更新代码
请输入选项对应序号：
""",end='')
  act=int(input())
  if type(act)!=int or act>10 or act<1 :
    print("选项不存在，退出")
    exit(0)
  if act==1:node_ins()
  if act==2:wk_ins()
  if act==3:add_phy()
  if act==4:wk_list()
  if act==5:node_status()
  if act==6:node_remove()
  if act==7:sgx_check()
  if act==8:self_update()
  save_cfg()
