phala_scripts_install_intel_sgx_deb="https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key"
phala_scripts_install_intel_addapt_deb="deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main"
phala_scripts_install_intel_old_device="https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.41.bin"
# phala_scripts_install_intel_old_device_2_11="https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin"
phala_scripts_install_intel_old_device_2_11="https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.054c9c4c.bin"
phala_scripts_install_setupnode="https://deb.nodesource.com/setup_lts.x"




phala_scripts_support_system=( "Ubuntu 18.04" "Ubuntu 20.04")
#function phala_scripts_check_system() {
  if [ -f /etc/lsb-release ];then
    . /etc/lsb-release
    [[ "${phala_scripts_support_system[@]}" =~ "${DISTRIB_ID} ${DISTRIB_RELEASE}" ]] && _system_check=true
  fi
  if [ -z "$_system_check" ];then
    _phala_scripts_utils_printf_value="$(phala_scripts_checks_support)"
    phala_scripts_log error "Unsupported system! %s" cut
    return 1
  fi

function phala_scripts_install_sgx_default() {
  # install aesm encalave
  # curl -fsSL https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
  curl -fsSL ${phala_scripts_install_intel_sgx_deb} | apt-key add - && \
  # add-apt-repository -y "deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main" && \
  add-apt-repository -y "${phala_scripts_install_intel_addapt_deb}" && \
  # reinstall : fix apt upgrade
  # 21.10 sgx-aesm-service error skip aesm
  # apt reinstall -y libsgx-enclave-common sgx-aesm-service
  apt autoremove -y libsgx-enclave-common
  apt install -y libsgx-enclave-common 

}

function phala_scripts_install_sgx_k5_4(){

  type make dkms >/dev/null 2>&1 || apt install -y make dkms

  # _intel_base_url="https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server"
  # _dcap_driver_url="$(curl -fsSL ${intel_base_url}/driver_readme.txt|grep -vE "^$"|awk -F':' '/DCAP driver/ {print $2}'|sed 's/ //g')"
  # _oot_driver_url="$(curl -fsSL ${intel_base_url}/driver_readme.txt|grep -vE "^$"|awk -F':' '/OOT driver/ {print $2}'|sed 's/ //g')"

  [ -f ${phala_scripts_tools_dir}/sgx_linux_x64_driver_1.41.bin ] || {
    # curl -fsSL https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.41.bin -o ${phala_scripts_tmp_dir}/sgx_linux_x64_driver_1.41.bin && \
    curl -fsSL ${phala_scripts_install_intel_old_device} -o ${phala_scripts_tmp_dir}/sgx_linux_x64_driver_1.41.bin && \
    mv ${phala_scripts_tmp_dir}/sgx_linux_x64_driver_1.41.bin ${phala_scripts_tools_dir}/ 
  }
  bash ${phala_scripts_tools_dir}/sgx_linux_x64_driver_1.41.bin || echo
  # curl -fsSL https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.054c9c4c.bin -o ${phala_scripts_tmp_dir}/sgx_linux_x64_driver_oot.bin && \
  [ -f ${phala_scripts_tools_dir}/sgx_linux_x64_driver_oot.bin ] || {
    curl -fsSL ${phala_scripts_install_intel_old_device_2_11} -o ${phala_scripts_tmp_dir}/sgx_linux_x64_driver_oot.bin && \
    mv ${phala_scripts_tmp_dir}/sgx_linux_x64_driver_oot.bin ${phala_scripts_tools_dir}/
  }
  bash ${phala_scripts_tools_dir}/sgx_linux_x64_driver_oot.bin
  # }

}


CURRENT_DIR=$(dirname $(readlink -f "$0"))
phala_scripts_tools_dir=${CURRENT_DIR}/../tools/
echo "Kernel ${_kernel_version}" cut
echo "Install Sgx device"
  if [ -c /dev/sgx_enclave ];then
    phala_scripts_install_sgx_default
  elif [ ${DISTRIB_RELEASE} == "20.04" ];then
    phala_scripts_install_sgx_k5_4 && \
    phala_scripts_install_sgx_default
  elif [ ${DISTRIB_RELEASE} == "18.04" ];then
    phala_scripts_install_sgx_k5_4
  fi
${CURRENT_DIR}/../tools/sgx_enable
${CURRENT_DIR}/../tools/sgx-detect


