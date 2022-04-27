 # set mnemonic gas_account_address
  local _mnemonic=""
  local _gas_adress=""
  local _balance=""
  while true ; do
    _mnemonic=$(phala_scripts_utils_read "Enter your gas account mnemonic")
    if [ -z "${_mnemonic}" ] || [ "$(node ${phala_scripts_tools_dir}/console.js utils verify "$_mnemonic")" == "Cannot decode the input" ]; then
      phala_scripts_log warn "Please enter a valid mnemonic, and it cannot be empty!" cut
    else
      _gas_adress=$(node ${phala_scripts_tools_dir}/console.js utils verify "$_mnemonic")
      _balance=$(node  ${phala_scripts_tools_dir}/console.js --substrate-ws-endpoint "${phala_scripts_public_ws}" chain free-balance $_gas_adress 2>&1)
      _balance=$(echo $_balance | awk -F " " '{print $NF}')
      [ -z "${_balance}" ] && _balance=0
      _balance=$(echo "$_balance / 1000000000000"|bc)
      if [ `echo "$_balance > 0.1"|bc` -eq 1 ]; then
        export phala_scripts_config_input_mnemonic=${_mnemonic}
        export phala_scripts_config_gas_account_address=${_gas_adress}
        break
      else
        phala_scripts_log warn "You have less than 0.1 PHA in your account!" cut
      fi
    fi
  done
  
  # set operator
  local _pool_addr=""
  while true ; do
    local _pool_addr=$(phala_scripts_utils_read "Enter your pool owner's address")
    if [ -z "${_pool_addr}" ] || [ "$(node ${phala_scripts_tools_dir}/console.js utils verify "$_pool_addr")" == "Cannot decode the input" ]; then
      phala_scripts_log warn "Please enter a valid pool owner's address, and it cannot be empty!"
    else
      export phala_scripts_config_input_operator=${_pool_addr}
      break
    fi
  done
