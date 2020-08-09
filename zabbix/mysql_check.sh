#!/bin/bash
#copyright by hwb
#check MySQL_Slave Status
#crontab time 00:10
ip="xx.xx"
date=`date +"%y%m%d-%H:%M:%S"`
#这里要输出3306
port=`netstat -ntlp | grep 3306 | awk '{print $4}' | awk -F":" '{print $2}'`
num=`mysql --login-path=mydb -e "show slave status\G" | grep Seconds_Behind_Master | awk '{print $2}'`
array=($(mysql --login-path=mydb -e "show slave status\G"|egrep "Running|Seconds_Behind_Master" | awk '{print $2}'))
#echo ${array[0]}
#echo ${array[1]}
#echo ${array[2]}

#mysql服务状态监控
if [ "$port" == "3306" ];then
 echo "mysql is running"
 #主从复制存活状态监控
 #if [ "${array[0]}" == "Yes" ] && [ "${array[1]}" == "Yes" ] && [ "${array[2]} " == "0" ]; then
 if [ "${array[0]}" == "Yes" ] && [ "${array[1]}" == "Yes" ]; then
 echo "MySQL slave status is ok !"
 else
 echo "####### $date #########">> /home/check_mysql_slave.log
 echo "Slave is not running!" >> /home/check_mysql_slave.log
 echo "Slave is not running!" | mail -s "warn!$ip MySQL Slave is not OK！" huangwb@fslgz.com
 fi
 #主从复制延时时间监控
 if [ $num -eq 0 ];then
 echo "Master and slave replication is consistent" 
 else
 echo "Master and slave replication is inconsistent" | mail -s "WARN! $ip MySQL Slave is inconsistent" huangwb@fslgz.com
 fi
else
 echo "Mysql is not running!" | mail -s "warn! $ip mysql is not running" 654796756@qq.com
fi