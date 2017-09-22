#!/bin/bash
# Date 2017-7-29
# Author:ZhangJian
# Mail:1037509307@qq.com
# Func:Configure Network Bonding for KUX 3.0
# Version:1.9

Func_get_group_slave_name(){
# 选择绑定主网卡
#tput cup 10;tput ed
print_menu_0 tips
echo -e "\033[031m${#Array_nic_list[@]}\033[0m network cards available:"
echo -e "\033[31m${Array_nic_list[@]}\033[0m"
echo -e "----------------------------------------------\n"

while true; do
    echo -e "\nPlease enter the primary NIC:_\b\c"
    read nic1
    echo ${Array_nic_list[@]} | grep -Fw "$nic1" &> /dev/null
    if [[ $? -eq 0 ]]; then
      break
    else
      #tput cup 10;tput ed
      print_menu_0 tips
      echo -e "\033[031m${#Array_nic_list[@]}\033[0m network cards available:\n\033[31m${Array_nic_list[@]}\033[0m"
      echo -e "----------------------------------------------\n"
      echo -e "\033[31m${nic1}\033[0m is not available,Please enter another one."
    fi
done

  # 重新对数组进行赋值，更清晰的显示系统中的可用网卡
	nic_name_unused=`echo "${nic_name_unused}" | grep -Fwv "${nic1}"`
	Array_nic_list=(${nic_name_unused})
	#tput cup 10;tput ed
  print_menu_0 tips
	echo -e "\033[031m${#Array_nic_list[@]}\033[0m network cards available:\n\033[31m${Array_nic_list[@]}\033[0m"
	echo -e "\nThe information you have entered:\nprimary NIC   : ${nic1}"
	echo -e "----------------------------------------------\n"
  #选择要绑定的辅网卡
	while true; do
	    echo -e "\nPlease select the secondary NIC:_\b\c"
	    read nic2
	    echo ${Array_nic_list[@]} | grep -Fw "${nic2}" &> /dev/null
	    if [[ $? -eq 0 ]]; then
	        #info_print "${nic_name_group}"
	        print_menu_0 tips
	        echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}"
	        echo -e "----------------------------------------------\n"
	        break
	    else
	        #tput cup 10;tput ed
          print_menu_0 tips
	        echo -e "\033[031m${#Array_nic_list[@]}\033[0m network cards available:\n\033[31m${Array_nic_list[@]}\033[0m\n"
	        echo -e "The information you have entered:\nprimary NIC   : ${nic1}"
	        echo -e "----------------------------------------------\n"
	        echo -e "\033[31m${nic2}\033[0m is not available,Please enter another one."
	    fi
	done
}

Func_get_group_name(){
#输入要team或bond名称
if [[ -z ${nic_name_group} ]]; then
    group_name="${nic_type}0"
    #info_print
    #tput cup 10;tput ed
    print_menu_0 tips
    echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}\ngroup name    : ${group_name}"
    echo -e "----------------------------------------------\n"
    echo "The default first group name is -- ${nic_type}0."
else
    while true; do
        echo -e "\nPlease enter a group name[${nic_type}N]:_\b\c"
        read group_name
        #检查输入格式是否为bond+数字或team+数字的格式。
        echo "${group_name}" | grep -wE "^${nic_type}[[:digit:]]+$" &> /dev/null
	    if [[ $? -eq 0 ]]; then
	        echo "${nic_name_group}" | grep -Fw "${group_name}" &> /dev/null
	        if [[ $? -ne 0 ]]; then
	          #info_print "${nic_name_group}"
	          print_menu_0 tips
	          #tput cup 10;tput ed
	          #echo -e "Already existing Bonding or Team Interface of the system:\n\033[31m${nic_name_group}\033[0m\n"
	          echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}\ngroup name    : ${group_name}"
	          echo -e "----------------------------------------------\n"
	          break
	        else
	          #info_print "${nic_name_group}"
	          #tput cup 10;tput ed
	          #echo -e "Already existing Bonding or Team Interface of the system:\n\033[31m${nic_name_group}\033[0m\n"
	          print_menu_0 tips
	          echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}"
	          echo -e "----------------------------------------------\n"
	          echo "You can not use an existing name: ${group_name}"
	          echo -e "\033[31m${group_name}\033[0m is not available,Please enter another one like -- ${nic_type}N."
	      	fi
	    else
	        #info_print "${nic_name_group}"
	        #tput cup 10;tput ed
	        #echo -e "Already existing Bonding or Team Interface of the system:\n\033[31m${nic_name_group}\033[0m\n"
	        print_menu_0 tips
	        echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}"
	        echo -e "----------------------------------------------\n"
	        echo -e "\033[31m${group_name}\033[0m is not available,Please enter another one like -- ${nic_type}N."
	    fi
    done
fi
}

Func_get_ip_address(){
#获取要绑定的IP地址
while true; do
    echo -e "\nPlease enter an IP address:_\b\c"
    read ip_bind
    #检查IP格式及范围是否正确
    echo "${ip_bind}" | grep -owE '^(([1-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-4])$' &> /dev/null
    if [[ $? -eq 0 ]]; then
    	#tput cup 10;tput ed
      print_menu_0 tips
  		echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}\ngroup name    : ${group_name}\nIP address    : ${ip_bind}"
  		echo -e "----------------------------------------------\n"
  		break
    else
    	#tput cup 10;tput ed
      print_menu_0 tips
  		echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}\ngroup name    : ${group_name}"
  		echo -e "----------------------------------------------\n"
  		echo -e "IP address: \033[31m${ip_bind}\033[0m format errors, please re-enter."
    fi
done
}

Func_get_netmask(){
#获取要配置的子网掩码
  while true; do
    echo -e "\nPls enter the NETMASK[255.255.255.0]:_\b\c"
    read netmask_bind
    netmask_bind=${netmask_bind:="255.255.255.0"}   #当变量为NETMASK_bind为空时，给其赋默认值255.255.255.0
    #检查子网掩码格式及范围
    echo "$netmask_bind" | grep -owE '^(128|192|224|240|248|252|254|255)\.((0|128|192|224|240|248|252|254|255)\.){2}(0|128|192|224|240|248|252|254|255)$' &> /dev/null
    if [[ $? -eq 0 ]]; then

      #计算掩码位数
      declare Array_mask1=(`echo ${netmask_bind} | sed 's/\./ /g'`)
      declare Array_mask2=(0 128 192 224 240 248 252 254 255)
      netmask_bit=0
      for (( j = 0; j <= 3; j++ )); do
          for (( i = 0; i <= 8; i++ )); do
              if [[ ${Array_mask1[$j]} -eq ${Array_mask2[$i]} ]]; then
                  ((netmask_bit+=i))
              fi
          done
      done
      break
    else
      #info_print
      #tput cup 10;tput ed
      print_menu_0 tips
      echo -e "The information you have entered:\nprimary NIC   : ${nic1}\nsecondary NIC : ${nic2}\ngroup name    : ${group_name}\nIP address    : ${ip_bind}"
      echo -e "----------------------------------------------\n"
      echo -e "Input error.\nPlease enter the correct NETMASK or press ENTER to use 255.255.255.0.\n"
    fi
  done
}


bonding(){
#创建bond的函数
nmcli connection add type bond ifname ${3} con-name ${3} autoconnect yes miimon 100 mode active-backup primary ${1} ip4 ${4}/${5}
sed -i 's/\(IPV6.*=\)yes/\1no/' ${net_base_dir}/ifcfg-${3} &> /dev/null
nmcli connection add type bond-slave ifname ${1} con-name ${3}-p1 autoconnect yes master ${3}
nmcli connection add type bond-slave ifname ${2} con-name ${3}-p2 autoconnect yes master ${3}
# 启动接口前最好重启下NetworkManager，否则可能出现接口启动失败的情况。
systemctl restart NetworkManager
nmcli connection up ${3}-p1 2> /dev/null || nmcli connection up ${3}-p1
nmcli connection up ${3}-p2 2> /dev/null || nmcli connection up ${3}-p2
nmcli connection up ${3} 2> /dev/null || nmcli connection up ${3}
}

Func_group_del(){
# 新建绑定之前，将系统中存在的未使用的绑定配置文件删除
# 使用方法 Func_group_del
net_base_dir=${net_base_dir:=/etc/sysconfig/network-scripts}
for i in $(cd ${net_base_dir} && ls ifcfg-*); do
     grep -w "^DEVICE=${1}" ${net_base_dir}/${i} &> /dev/null
     if [[ $? -eq 0 ]]; then
        rm -rf ${net_base_dir}/${i}
     fi

    grep -w "^DEVICE=${2}" ${net_base_dir}/${i} &> /dev/null
    if [[ $? -eq 0 ]]; then
        rm -rf ${net_base_dir}/${i}
    fi

     grep -w "^MASTER=${3}" ${net_base_dir}/${i} &> /dev/null
    if [[ $? -eq 0 ]]; then
        rm -rf ${net_base_dir}/${i}
    fi
done

nmcli device delete ${3} &> /dev/null
nmcli connection delete ${3}-p1 &> /dev/null
nmcli connection delete ${3}-p2 &> /dev/null
nmcli connection delete ${3} &> /dev/null
}

Func_confirm_info(){
#最终输入信息确认
  while true; do
    #info_print
    #tput cup 10;tput ed
    print_menu_0 tips
    echo -e "The information you have entered:\n"
    echo -e "\033[31mprimary NIC   :${nic1}\nsecondary NIC :${nic2}\ngroup name    :${group_name}\nIP address    :${ip_bind}\nNETMASK       :${netmask_bind}\033[0m"
    echo -e "----------------------------------------------\n"
    echo -e "Pls make sure its OK[y/n]:_\b\c"
    read input
    case ${input} in
      [Yy]|[Yy][Ee][Ss] )
        for i in `cd ${net_base_dir} && ls ifcfg-*`; do
            Func_file_backup "${net_base_dir}/$i" "${net_base_dir}/inspur_bak" "-M"
        done
        #不让其开机自启动，虚拟机重启网络服务会报错
        systemctl enable NetworkManager-wait-online.service &> /dev/null
        if [[ ${nic_type} == bond ]]; then
          Func_group_del "$nic1" "$nic2" "$group_name"
          #创建bond
          bonding "$nic1" "$nic2" "$group_name" "$ip_bind" "$netmask_bit"
          exit 0
        elif [[ ${nic_type} == team ]]; then
          Func_group_del "$nic1" "$nic2" "$group_name"
          #创建team
          teaming "$nic1" "$nic2" "$group_name" "$ip_bind" "$netmask_bit"
          exit 0
        fi
        break
        ;;
      [Nn]|[Nn][Oo] )
        main
      ;;
      * )
        print_error_info 5
      ;;
    esac
  done
}


Func_nic_not_enough(){
#提示网卡数量少于2块，不可用于绑定
  #info_print
  #tput cup 10;tput ed
  print_menu_0 tips
  echo -e "You have \033[031m${#Array_nic_list[@]}\033[0m network cards available:\n"
  #将重点显示的“网卡名”标示为红色
  echo -e "\033[31m${Array_nic_list[@]}\033[0m\n"
  echo -e "There are \033[31mnot enough\033[0m network cards to make bonding or team."
  echo -e "Pls check it......\n"
  echo -e 'Press ENTER to exit..._\b\c'
  read answer
  exit 1
}


print_help_info(){
#帮助信息,用于main函数中
trap "tput clear;tput cup 3;echo 'Any Questions: Send a message to QQ 1037509307.';tput cup 6;exit" 2 3
if [[ -n $1 ]]; then
  cat <<EOF

Network Configuration Assistant
                    --- Configure Network Bonding v1.9

Usage:

        sh $0
        chmod +x $0 && ./$0

EOF
exit 0
fi
}

check_root_user(){
#用户限定，用于main函数中
if [[ $UID -ne 0 ]]; then
  tput clear
  tput cup 6 20
  echo -e "You must use the user: \033[31mROOT\033[0m"
  tput cup 10
  exit
fi
}

print_error_info(){
#错误提示函数，用于非main函数中
tput cup $1 $2;tput ed   #向下清屏
echo 'Input error,Try again pls.'
echo -e 'Press ENTER to continue..._\b\c'
read inputA
}

Func_file_backup(){
#文件备份函数,用于非main函数中
#使用方法：
#file_backup 要备份的文件名 备份目录 -x(按什么时间格式备份)
case ${3} in
    -d )  #按天备份
        Bak_Date=`date '+%Y-%m-%d'`
        ;;
    -H ) #按小时备份
        Bak_Date=`date '+%Y-%m-%d_%H'`
        ;;
    -M ) #按分钟备份
        Bak_Date=`date '+%Y-%m-%d_%H:%M'`
        ;;
    -m ) #按月备份
        Bak_Date=`date '+%Y-%m'`
        ;;
    -Y ) #按年备份
        Bak_Date=`date '+%Y'`
        ;;
    * ) #默认按分钟备份
        Bak_Date=`date '+%Y-%m-%d_%H:%M'`
        ;;
esac
#Bak_Date=`date '+%Y-%m-%d-%H:%M'`

[[ -d ${2}/${Bak_Date} ]] || mkdir -p ${2}/${Bak_Date}
cp -ra ${1} ${2}/${Bak_Date} && echo "File backup directory: ${2}/${Bak_Date}"
}



print_menu_0(){

#tput clear;tput cup 2
tput clear;tput cup 1
#tput clear;tput cup 5
cat <<EOF
----------------------------------------------
------  Network Configuration Assistant ------
----------------------------------------------
EOF
#tput cup 10
tput cup 5;tput ed
if [[ ${1} == tips ]]; then
	if [[ -n ${NIC_NAME_bond}${NIC_NAME_team} ]]; then
		#echo -e "Already existing Bonding or Team Interface of the system:\n\033[31m${nic_name_group}\033[0m\n"
    echo -e "Already existing Bonding or Team Interface of the system:"
    if [[ ${#Array_bond_group[@]} -ne 0 ]]; then
      for (( i = 0; i <= ${#Array_bond_group[@]}; i++ )); do
        echo -e "\033[31m${Array_bond_group[$i]}\033[0m"
      done
    fi


    if [[ ${#Array_team_group[@]} -ne 0 ]]; then
      for (( i = 0; i <= ${#Array_team_group[@]}; i++ )); do
        echo -e "\033[31m${Array_team_group[$i]}\033[0m"
      done
    fi
  fi
fi

if [[ $1 == logo ]]; then
# 以下的logo信息共8行
tput cup 0;tput ed
cat <<'EOF'
 _____                   ____  __         _____           _
| ____|__ _ ___ _   _   / ___|/ _| __ _  |_   _|__   ___ | |___
|  _| / _` / __| | | | | |   | |_ / _` |   | |/ _ \ / _ \| / __|
| |__| (_| \__ \ |_| | | |___|  _| (_| |   | | (_) | (_) | \__ \
|_____\__,_|___/\__, |  \____|_|  \__, |   |_|\___/ \___/|_|___/
                |___/             |___/

                              -- Network Configuration Assistant
EOF
# 将光标定位到第10行
tput cup 10
fi
}


print_menu_1(){
print_menu_0 logo
cat <<'EOF'
1 ) Configure Bond
2 ) Configure Team
3 ) Configure IP Address
4 ) View binding information
----------------------------------------------
EOF
echo -e "Please make your choice[1-4]: _\b\c"
read get_menu_1
case ${get_menu_1} in
	1 )
		Configure_Bond
		;;
	2 )
		Configure_Team
		;;
	3 )
		Configure_IP_Add
		;;
	4 )
		View_binding_info
		;;
	* )
		print_error_info 10
		print_menu_1
		;;
esac
}


Configure_Bond(){
#print_menu_0
print_menu_0 tips
cat <<'EOF'
1 ) Create Bond
2 ) Delete Bond
3 ) Modify Bond mode
4 ) Configure IP Address
----------------------------------------------
EOF
echo -e "Please make your choice[1-4]: _\b\c"
read get_bond
case ${get_bond} in
	1 )
		if [[ "${#Array_nic_list[@]}" -gt 1 ]]; then
			    nic_type=bond
	        #绑定网卡赋值，用于后续判断系统中是否存在team
	        nic_name_group=${NIC_NAME_bond}
	        Func_get_group_slave_name
	        Func_get_group_name
	        Func_get_ip_address
	        Func_get_netmask
	        Func_confirm_info			#statements
	  else
	    	  Func_nic_not_enough
		fi
		;;
	2 )
		echo 'Please wait for the next release.'
		;;
	3 )
		echo 'Please wait for the next release.'
		;;
	4 )
		echo 'Please wait for the next release.'
		;;
	* )
		print_error_info 5
		Configure_Bond
		;;
esac
}


#将 print_menu_0 logo 中的logo换成别的字符将不显示logo
main(){
print_help_info
check_root_user
net_base_dir=/etc/sysconfig/network-scripts
lang_var=$LANG
LANG=EN
NIC_NAME_all=`nmcli device status | awk '$2 == "ethernet"  {print $1}'`
#NIC_NAME_all=`nmcli connection show | awk '{if ($3~/ethernet/) print $1}'`
#绑定网卡
NIC_NAME_bond=`nmcli device status  | awk '$2 == "bond" && $3 != "unmanaged" {print $1}'`
NIC_NAME_team=`nmcli device status  | awk '$2 == "team" && $3 != "unmanaged" {print $1}'`
LANG=${lang_var}
#绑定网卡的子网卡
if [[ -n ${NIC_NAME_bond} ]]; then
  num=0
  for i in ${NIC_NAME_bond}; do
    #取所有已经使用属于bond的子网卡bond_slave_nic
    bond_slave_nic_var=$(cat /sys/class/net/${i}/bonding/slaves)
    bond_slave_nic="${bond_slave_nic_var} ${bond_slave_nic}"
    #将bond的信息以  "bondN=salve1 slave2"  的形式放进数组中
    bond_slave_nic_var=$(echo ${bond_slave_nic_var})
    declare Array_bond_group[${num}]="${i}=${bond_slave_nic_var}"
    let num++
  done  #statements
fi


#取得所有已经属于team的子网卡team_slave_nic
if [[ -n ${NIC_NAME_team} ]]; then
  num=0
  for i in ${NIC_NAME_team}; do
    team_conf=$(teamdctl ${i} config dump)
    for j in ${NIC_NAME_all}; do
      team_slave_nic_var=$(echo "${team_conf}" | grep -wo "${j}")
      team_slave_nic="${team_slave_nic} ${team_slave_nic_var}"
    done
    #将team的信息以  "teamN=salve1 slave2"  的形式放进数组中
    #首先去除变量中包含的空格
 	team_slave_nic=$(echo ${team_slave_nic})
    declare Array_team_group[${num}]="${i}=${team_slave_nic}"
    let num++
  done
fi
bond_slave_nic=${bond_slave_nic:=NULL}
team_slave_nic=${team_slave_nic:=NULL}

#尚未被绑定的网卡名称 nic_name_unused
nic_name_unused="${NIC_NAME_all}"

#从所有网卡中去除team子网卡
if [[ ${team_slave_nic} != NULL ]]; then
  for i in ${team_slave_nic}; do
    nic_name_unused=$(echo "${nic_name_unused}" | grep -Fwv "${i}")
  done
fi

#从所有网卡中去除bond子网卡
if [[ ${bond_slave_nic} != NULL ]]; then
  for i in ${bond_slave_nic}; do
    nic_name_unused=$(echo "${nic_name_unused}" | grep -Fwv "${i}")
  done
fi

#将可用网卡导入数组中
declare Array_nic_list=(${nic_name_unused})

print_menu_1
}
main_baby

hello baby
test

123
