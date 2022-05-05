alias cdepha="cd /opt/fctok/EasyPhalaCluster/"
alias bashrc="vim ~/.bashrc;source ~/.bashrc"
git clone https://github.com/FkerYJ/EasyPhalaCluster /opt/fctok/EasyPhalaCluster
chmod 777 /opt/fctok/EasyPhalaCluster/run.sh
ln -s /opt/fctok/EasyPhalaCluster/run.sh /usr/bin/epha
