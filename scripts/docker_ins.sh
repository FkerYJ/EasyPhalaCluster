CURRENT_DIR=$(dirname $(readlink -f "$0"))
PHALA_LANG=CN
phala_scripts_tools_dir=${CURRENT_DIR}/../tools/
phala_scripts_tmp_dir=/tmp
phala_scripts_utils_apt_source_cn="https://mirrors.163.com"
phala_scripts_install_docker_compose_cn="https://get.daocloud.io/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)"
phala_scripts_install_docker_compose="https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)"
[ -z "${phala_scripts_dir}" ] && phala_scripts_dir=$(cd $(dirname $0);pwd)
#source
. ${phala_scripts_dir}/log.sh


phala_scripts_dependencies_default_soft=(
  jq curl wget unzip zip gettext
)
# docker-compose: docker + docker-compose
phala_scripts_dependencies_other_soft=(
  docker docker-compose node
)




function phala_scripts_install_aptdependencies() {
  if [ "$1" == "uninstall" ];then
    shift
    phala_scripts_log info "Uninstall Apt dependencies" cut
    apt autoremove -y $*
    return 0
  fi

  _default_soft=$*
  phala_scripts_log info "Apt update" cut
  apt update
  if [ $? -ne 0 ]; then
    phala_scripts_log error "Apt update failed."
  fi
  phala_scripts_log info "Installing Apt dependencies" cut
  apt install -y ${_default_soft[@]}
}

function phala_scripts_install_otherdependencies(){
  if [ "$1" == "uninstall" ];then
    shift
    phala_scripts_log info "Uninstall other dependencies" cut
    for _package in $*;do
      if ! type $_package > /dev/null 2>&1;then
        :
      else
        case $_package in
          docker)
            apt autoremove -y docker-ce docker-ce-cli
            find /etc/apt/sources.list.d -type f -name docker.list* -exec rm -f {} \;
          ;;
          docker-compose)
            [ -f /usr/local/bin/docker-compose ] && rm -rf /usr/local/bin/docker-compose
          ;;
          node)
            apt autoremove -y nodejs
            find /etc/apt/sources.list.d -type f -name nodesource.list* -exec rm -f {} \;
          ;;
          *)
            apt autoremove -y $_package
          ;;
        esac
      fi
    done
    return 0
  fi

  _other_soft=$*
  phala_scripts_log info "Installing other dependencies" cut
  echo $*
  for _package in ${_other_soft};do
    if ! type $_package >/dev/null 2>&1;then
      case $_package in
        docker-compose)
          if [ ! -f /usr/local/bin/docker-compose ];then
            if [ "${PHALA_LANG}" == "CN" ];then
              # curl -L "https://get.daocloud.io/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o ${phala_scripts_tmp_dir}/docker-compose && \
              curl -L "${phala_scripts_install_docker_compose_cn}" -o ${phala_scripts_tmp_dir}/docker-compose && \
              mv ${phala_scripts_tmp_dir}/docker-compose /usr/local/bin/
            else
              # curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o ${phala_scripts_tmp_dir}/docker-compose && \
              curl -L "${phala_scripts_install_docker_compose}" -o ${phala_scripts_tmp_dir}/docker-compose && \
              mv ${phala_scripts_tmp_dir}/docker-compose /usr/local/bin/
            fi
          fi
          chmod +x /usr/local/bin/docker-compose
        ;;
        docker)
          find /etc/apt/sources.list.d -type f -name docker.list.* -exec rm -f {} \;
          if [ ! -f "${phala_scripts_tools_dir}/get-docker.sh" ];then
            curl -fsSL get.docker.com -o ${phala_scripts_tools_dir}/get-docker.sh
          fi

          # set cn
          if [ "${PHALA_LANG}" == "CN" ];then
            bash ${phala_scripts_tools_dir}/get-docker.sh --mirror Aliyun || :
            # # disable cn; error
            # systemctl stop docker.socket
            # [ -d /etc/docker ] || mkdir /etc/docker  
            # printf '{\n  "registry-mirrors": [\n    "https://docker.mirrors.ustc.edu.cn"\n  ]\n}' > /etc/docker/daemon.json
            # systemctl start docker.socket
            
          else
            bash ${phala_scripts_tools_dir}/get-docker.sh || :
          fi
          type docker || phala_scripts_log "Docker Install Fail"
        ;;
        node)
          find /etc/apt/sources.list.d -type f -name 'nodesource.list.*' -exec rm -f {} \;
          if [ ! -f "${phala_scripts_tools_dir}/get-node.sh" ];then
            # curl -fsSL https://deb.nodesource.com/setup_lts.x -o ${phala_scripts_tools_dir}/get-node.sh
            curl -fsSL ${phala_scripts_install_setupnode} -o ${phala_scripts_tools_dir}/get-node.sh
          fi
          bash ${phala_scripts_tools_dir}/get-node.sh
          apt-get install -y nodejs
        ;;
      esac
    fi
  done

}



phala_scripts_install_aptdependencies  ${phala_scripts_dependencies_default_soft[@]}
phala_scripts_install_otherdependencies ${phala_scripts_dependencies_other_soft[@]}
systemctl restart docker
