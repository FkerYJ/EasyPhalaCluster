export http_proxy=http://127.0.0.1:8890/
export https_proxy=http://127.0.0.1:8890/

git clone https://github.com/FkerYJ/EasyPhalaCluster /opt/fctok/EasyPhalaCluster
chmod 777 /opt/fctok/EasyPhalaCluster/run.sh
source /opt/fctok/EasyPhalaCluster/scripts/env.sh
ln -s /opt/fctok/EasyPhalaCluster/run.sh /usr/bin/epha
