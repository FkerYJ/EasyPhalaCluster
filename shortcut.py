import sys,os.path as path,os
import time,re

with open("~/.bashrc",a+) as fa:
  txt=fa.readlines()
  pattern = re.compile(r'_phasc_')
  txt.re