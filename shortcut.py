import sys,os.path as path,os
import time,re

def add_bashrc():
  fr=open("/root/.bashrc","a+")
  fr.seek(0,0)
  txt=fr.read();fr.close()
  pattern = re.compile(r'#_phasc_start[\s\S]*#_phasc_end')
  pyload="""
#_phasc_start
alias cdepha="cd /opt/fctok/EasyPhalaCluster/"
alias bashrc="vim ~/.bashrc;source ~/.bashrc"
alias profile="vim ~/.profile;source ~/.profile"
alias dk="docker"
alias apti="apt install"
alias aptr="apt autoremove"
alias rf="rm -rf"
#_phasc_end
  """
  result = pattern.findall(txt)
  if len(result):
    print("Alias found,Replaced")
    txt=pattern.sub("",txt)
  fw=open("/root/.bashrc","w+")
  txt=pyload+txt
  fw.write(txt)
  fw.close()
  os.system("bash -c \"source ~/.bashrc\"")
    

add_bashrc()