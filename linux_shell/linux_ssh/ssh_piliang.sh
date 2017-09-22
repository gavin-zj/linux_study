#!/bin/bash
#zhangjian
#2017-8-31 16:00:20
#For SSH

#添加上是否需要创建机器自身的互信
local_user=$(whoami)
ssh_dir=/tmp/.ssh_id
if [[ -d ${ssh_dir} ]]; then
    cd ${ssh_dir} && rm -rf id_rsa*
else
    mkdir -p /tmp/.ssh_id
fi
ssh_dir=${ssh_dir:="/tmp/.ssh_id"}
chmod -R 777 ${ssh_dir}

create_local_id(){
# 创建本机的rsa
[[ -e ~/.ssh/id_rsa ]]  || ssh-keygen -q -t rsa  -N '' -f  ~/.ssh/id_rsa
}

create_remote_id(){
#创建远程主机rsa
expect -c "

spawn ssh ${ssh_remote_user}@${ssh_remote_ip} ssh-keygen -q -t rsa  -N '' -f  ~/.ssh/id_rsa
expect {
\"*yes/no)?\" {send \"yes\r\";exp_continue}
\"*password:\" {send \"${ssh_passwd}\r\";exp_continue}
\"*unreachable\" {exit 1}
\"*Permission denied*\" {exit 2}
\"*No route to host*\" {exit 3}
\"*failure*\" {exit 4}
\"*No such file or directory*\" {exit 5}
\"*No match*\" {exit 6}
\"*failed*\" {exit 7}
\"*(y/n)?\" {send \"n\"}
expect eof
}"
}

copy_id_local_to_remote(){
expect -c "

spawn ssh-copy-id ${ssh_remote_user}@${ssh_remote_ip}
expect {
\"*yes/no)?\" {send \"yes\r\";exp_continue}
\"*password:\" {send \"${ssh_passwd}\r\";exp_continue}
\"*unreachable\" {exit 1}
\"*Permission denied*\" {exit 2}
\"*No route to host*\" {exit 3}
\"*failure*\" {exit 4}
\"*No such file or directory*\" {exit 5}
\"*No match*\" {exit 6}
\"*failed*\" {exit 7}
\"*(y/n)?\" {send \"n\"}
expect eof
}"
}


copy_id_remote_to_local(){
# 拷贝远程主机密钥至本机
expect -c "

spawn scp ${ssh_remote_user}@${ssh_remote_ip}:~/.ssh/id_rsa.pub ${ssh_dir}/id_rsa.pub.${ssh_remote_ip}
expect {
\"*yes/no)?\" {send \"yes\r\";exp_continue}
\"*password:\" {send \"${ssh_passwd}\r\";exp_continue}
\"*unreachable\" {exit 1}
\"*Permission denied*\" {exit 2}
\"*No route to host*\" {exit 3}
\"*failure*\" {exit 4}
\"*No such file or directory*\" {exit 5}
\"*No match*\" {exit 6}
\"*failed*\" {exit 7}
\"*(y/n)?\" {send \"n\"}
expect eof
}"

}



main(){
ssh_flag=0
    for line in $(cat $1 |sed 's/[[:space:]+]/++/g') ; do
        ssh_remote_user=$(echo "$line" | awk -F '++' '{print $1}')
        ssh_passwd=$(echo "$line" | awk -F '++' '{print $2}')
        ssh_remote_ip=$(echo "$line" | awk -F '++' '{print $3}')
        if [[ ${ssh_flag} -eq 0 ]]; then
            # 这里最好检测下获取到的IP地址是否在本机存在，若不存在，则进行提醒。
            ssh_local_user=${ssh_remote_user}
            ssh_local_ip=${ssh_remote_ip}
            ssh_flag=1
            if [[ ${local_user} == ${ssh_local_user} ]]; then
                ifconfig | grep "${ssh_local_ip}" &>/dev/null
                if [[ $? -eq 0 ]]; then
                    create_local_id
                else
                    tput clear
                    tput cup 2
                    echo -e "The IP address cannot be found: ${ssh_local_ip}"
                    echo -e "Check the configuration file pls."
                    exit
                fi
            else
                tput clear
                tput cup 2
                echo -e "Please execute the script by user: ${ssh_local_user}."
                exit
            fi
        else
            ping -c 2 -W 2 ${ssh_remote_ip} &> /dev/null
            if [[ $? -eq 0 ]]; then
                create_remote_id
                copy_id_local_to_remote
                copy_id_remote_to_local
            else
                break
            fi
        fi
    done

    for i in $(ls ${ssh_dir}); do
        cat ${ssh_dir}/$i >> ~/.ssh/authorized_keys
    done
    chmod 600  ~/.ssh/authorized_keys &>/dev/null
    rm -rf ${ssh_dir}
}


main $1