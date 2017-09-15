#!/bin/bash
cur_dir=$(pwd)
log_file=${cur_dir}/log
if [[ -f ${log_file} ]]; then
    > ${log_file}
else
    touch ${log_file}
fi

func_log(){
    #name(任务名称)  执行结果描述  日志文件
    echo -e "\nTASK: [$(hostname) | ${1}] ===>>>" | tee -a $3
    echo -e "${2}\n" | tee -a $3
}

func_check_name(){
    if [[ -z $1 ]]; then
        func_log "no name" "failed: pls check config file." ${log_file}
        exit 1
    fi
}



func_service(){
    #使用方法：func_service “任务描述” "任务选项"
    local key
    local value
    declare array_service
    array_service=($2)
    for (( i = 0; i < ${#array_service[@]}; i++ )); do
        key=$(echo ${array_service[$i]} | cut -d '=' -f 1)
        if [[ -z ${key} ]]; then
            func_log "$1" "failed: something wrong with ${array_service[$i]}" ${log_file}
            exit 1
        fi
        value=$(echo ${array_service[$i]} | cut -d '=' -f 2)
        if [[ -z ${value} ]]; then
            func_log "$1" "failed: something wrong with ${array_service[$i]}" ${log_file}
            exit 1
        fi
        case ${key} in
            name )
                service_name=${value}
                ;;
            state )
                service_state=${value}
                ;;
            onboot )
                service_onboot=${value}
                ;;
            * )
                func_log "$1" "failed: something wrong with ${array_service[$i]}" ${log_file}
                ;;
        esac
    done

    which systemctl &> /dev/null
    if [[ $? -eq 0 ]]; then
        systemctl ${service_state} ${service_name} &>/dev/null
        if [[ $? -eq 0 ]]; then
            current_state=$(systemctl status ${service_name} | grep -E '^[[:space:]]+Active' | awk -F '[(|)]' '{print $2}')
            func_log "$1" "success: ${service_state} ${service_name} current_state=${current_state}" ${log_file}
        else
            func_log "$1" "failed: ${service_state} ${service_name}" ${log_file}
        fi
        if [[ -n ${service_onboot} ]]; then
            case ${service_onboot} in
                yes )
                    systemctl enable ${service_name} &>/dev/null
                    if [[ $? -eq 0 ]]; then
                        func_log "$1" "success: onboot=yes ${service_name}" ${log_file}
                    else
                        func_log "$1" "failed: onboot=yes ${service_name}" ${log_file}
                    fi
                    ;;
                no )
                    systemctl disable ${service_name} &>/dev/null
                    if [[ $? -eq 0 ]]; then
                        func_log "$1" "success: onboot=no ${service_name}" ${log_file}
                    else
                        func_log "$1" "failed: onboot=no ${service_name}" ${log_file}
                    fi
                   ;;
                * )
                    func_log "$1" "failed: pls check the config file" ${log_file}
                    ;;
            esac
        fi
    else
        service ${service_name} ${service_state} &>/dev/null
        if [[ $? -eq 0 ]]; then
        current_state=$(service ${service_name} status)
            func_log "$1" "success: ${service_state} ${service_name} current_state=${current_state}" ${log_file}
        else
            func_log "$1" "failed: ${service_state} ${service_name}" ${log_file}
        fi
         if [[ -n ${service_onboot} ]]; then
            case ${service_onboot} in
                yes )
                    chkconfig ${service_name} on &>/dev/null
                    if [[ $? -eq 0 ]]; then
                        func_log "$1" "success: onboot=yes ${service_name}" ${log_file}
                    else
                        func_log "$1" "failed: onboot=yes ${service_name}" ${log_file}
                    fi
                    ;;
                no )
                    chkconfig ${service_name} off &>/dev/null
                    if [[ $? -eq 0 ]]; then
                        func_log "$1" "success: onboot=no ${service_name}" ${log_file}
                    else
                        func_log "$1" "failed: onboot=no ${service_name}" ${log_file}
                    fi
                   ;;
                * )
                    func_log "$1" "failed: pls check the config file" ${log_file}
                    ;;
            esac
        fi
    fi
}

func_file(){
    #使用方法：func_file "${name}" "${option}"
    local key
    local value
    declare array_file
    array_file=($2)
    #确保$2中的值为key=value的形式
    for (( i = 0; i < ${#array_file[@]}; i++ )); do
        key=$(echo ${array_file[$i]} | cut -d '=' -f 1)
        if [[ -z ${key} ]]; then
            func_log "$1" "failed: something wrong with ${array_file[$i]}" ${log_file}
            exit 1
        fi
        value=$(echo ${array_file[$i]} | cut -d '=' -f 2)
        if [[ -z ${value} ]]; then
            func_log "$1" "failed: something wrong with ${array_file[$i]}" ${log_file}
            exit 1
        fi

        case ${key} in
            state )
                file_state=${value}
                ;;
            src )
                file_src=${value}
                ;;
            dest )
                file_dest=${value}
                ;;
            * )
                func_log "$1" "failed: something wrong with ${array_file[$i]}" ${log_file}
                ;;
        esac
    done

    case ${file_state} in
        add )
            if [[ -n ${file_src} ]]; then
                if [[ -n ${file_dest} ]]; then
                    func_backup "${file_dest}"
                    cat ${file_dest}.bak.ori > ${file_dest} && cat ${file_src} >> ${file_dest}
                    if [[ $? -eq 0 ]]; then
                        func_log "$1" "success." ${log_file}
                    else
                        func_log "$1" "failed." ${log_file}
                    fi
                else
                    func_log "$1" "failed. bad configuration file,Missing option dest=" ${log_file}
                fi
            else
                func_log "$1" "failed. bad configuration file,Missing option src=" ${log_file}
            fi
            ;;
        * )
            func_log "$1" "failed: something wrong with --> config file: state" ${log_file}
            ;;
    esac
}


func_backup(){
    #使用方法：func_backup 备份文件
    if [[ -f $1 ]]; then
        if [[ -e ${1}.bak.ori ]]; then
            cp ${1} ${1}.$(date +%y%m%d-%T).bak || func_log "file backup" "failed. $1 backup failed" ${log_file}
        else
            cp ${1}{,.bak.ori} || func_log "file backup" "failed. $1 backup failed" ${log_file}
        fi
    fi
}

for line in $(cat conf | sed 's/ /++/g'); do
    line=$(echo $line | sed 's/++/ /g')
    echo $line | grep -Ew '^-name' &>/dev/null
    if [[ $? -eq 0 ]]; then
        name=$(echo $line | cut -d ':' -f 2)
    else
        flag=$(echo $line | cut -d ':' -f 1)
        case $flag in
            service )
                func_check_name "$name"
                option=$(echo ${line} | cut -d ':' -f 2)
                func_service "${name}" "${option}"
                unset name
                ;;
            file )
                func_check_name "$name"
                option=$(echo ${line} | cut -d ':' -f 2)
                func_file "${name}" "${option}"
                unset name
                ;;
        esac
    fi
done






===================================================
while [[ 1 ]]; do
select var in $(ls);do
echo $var
break
done
done


TASK: [nginx01 | Create Web Root] *********************************************
ok: [client01.example.com]

TASK: [nginx01 | ensure nginx is running] *************************************
changed: [client01.example.com]



-name:create user zj
user:name=zj uid=1111
-name:create user zj2
user:name=zj2 uid=1112

要去掉配置文件中#号开头的行。












