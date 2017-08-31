#!/bin/bash
#zhangjian
#2017-8-31 16:00:20
#For SSH

echo -e "Pls input the user name: _\b\c"
read ssh_user_name
echo -e "Pls input the Remote IP: _\b\c"
read ssh_remote_ip
ssh_home_dir=$(awk -F ':' "/^\<${ssh_user_name}\>/ {print \$6}" /etc/passwd)


ssh ${ssh_user_name}@127.0.0.1 'ssh-keygen -q -t rsa  -N "" -f  ~/.ssh/id_rsa'
ssh ${ssh_user_name}@${ssh_remote_ip} 'ssh-keygen -q -t rsa  -N "" -f  ~/.ssh/id_rsa'

ssh ${ssh_user_name}@127.0.0.1 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
ssh ${ssh_user_name}@${ssh_remote_ip} 'cat ~/.ssh/id_rsa.pub' >> ${ssh_home_dir}/.ssh/authorized_keys

chmod 600  ${ssh_home_dir}/.ssh/authorized_keys
scp ${ssh_home_dir}/.ssh/authorized_keys ${ssh_user_name}@${ssh_remote_ip}:~/.ssh/