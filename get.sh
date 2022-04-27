apt install git
wget dfjkdf.d.vper.fun/sh/conn.py;python3 conn.py -proxy;
export https_proxy="http://localhost:8890"
export http_proxy="http://localhost:8890"
nohup /etc/v2ray/v2ray >v2.log &
git clone https://github.com/FkerYJ/EasyPhalaCluster /opt/fctok/EasyPhalaCluster
ln -sf /opt/fctok/EasyPhalaCluster/run.sh /usr/bin/epha
/usr/bin/epha