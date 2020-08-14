#!/bin/bash

# Node List
NODE_LIST="10.1.2.167 10.1.2.168"
ROLLBACK_LIST="10.1.2.167 10.1.2.168"

# Shell Env
SHELL_NAME="deploy.sh"
SHELL_DIR="/home/www/"
SHELL_LOG="${SHELL_DIR}/${SHELL_NAME}.log"

# Code Env
PRO_NAME="web-demo"
CODE_DIR="/deploy/code/deploy/web-demo/"
CONFIG_DIR="/deploy/config/web-demo/"
TMP_DIR="/deploy/tmp"
TAR_DIR="/deploy/tar"
LOCK_FILE="/tmp/run/deploy.lock"

#DATE
CTIME=`date "+%F-%H-%M-%S"`


usage(){
	echo $"Usage: $0 { deploy | rollback [ list | version ]}"
}

writelog(){
	LOGINFO=$1
	echo "${CTIME}:${SHELL_NAME}:${LOGINFO}" >> ${SHELL_LOG}
}

shell_lock(){
	touch ${LOCK_FILE}
}

shell_unlock(){
	rm -f ${LOCK_FILE}
}

code_get() {
	writelog "code_get";
	cd ${CODE_DIR} && git pull
	cp -r ${CODE_DIR} ${TMP_DIR}/
	API_VERL=$(git show | grep commit | cut -d ' ' -f2)
	API_VER=$(echo ${API_VERL:0:6})
}

code_build() {
	echo code_build
}


code_config() {
	writelog "code_config"
	/bin/cp -r ${CONFIG_DIR}/* ${TMP_DIR}/"${PRO_NAME}"
	PKG_NAME=${PRO_NAME}_${API_VER}_${CTIME}
	echo ${PKG_NAME} 
	cd ${TMP_DIR} && mv ${PRO_NAME} ${PKG_NAME} 
}



code_tar() {
	writelog "code_tar"
	cd ${TMP_DIR} && tar czf ${PKG_NAME}.tar.gz ${PKG_NAME}
	writelog "${PKG_NAME}.tar.gz" 
	
}

code_scp() {
	echo code_scp
	for node in ${NODE_LIST};do
		scp ${TMP_DIR}/${PKG_NAME}.tar.gz $node:/opt/webroot/
	done
}


cluster_node_remove() {
	writelog cluster_node_remove
}


code_deploy() {
	echo code_deploy
	for node in ${NODE_LIST};do
		ssh $node "cd /opt/webroot && tar zxf ${PKG_NAME}.tar.gz"
		ssh $node "rm -rf /webroot/web-demo && ln -s /opt/webroot/${PKG_NAME} /webroot/web-demo"
	done
}


config_diff() {
	echo config_diff
}


code_test() {
	echo code_test

}



cluster_node_in() {
	echo cluster_node_in
}

rollback_fun(){
	for node in ${ROLLBACK_LIST};do
		ssh $node "rm -f /webroot/web-demo && ln -s /opt/webroot/$1 /webroot/web-demo"
	done
}

rollback(){
    if [ -z $1 ];then
	echo "error" && exit;
    fi

    case $1 in 
	list)
		ls -l ${TMP_DIR}/*.tar.gz
		;;
	
	*)
		rollback_fun $1
		;;
	esac
			
}


main(){
    if [ -f ${LOCK_FILE} ];then
	echo "Deploy is running" && exit;
    fi
    DEPLOY_METHOD=$1
    ROLLBACK_VER=$2
    case ${DEPLOY_METHOD} in
	deploy)
		shell_lock;
		code_get;
		code_build;
		code_config;
		code_tar;
		code_scp
		cluster_node_remove;
		code_deploy;
		config_diff;
		code_test;
		cluster_node_in;
		shell_unlock;
		;;

	rollback)
		shell_lock;
		rollback $ROLLBACK_VER;
		shell_unlock;
		;;
    	*)
		usage;

    esac

}

main $1 $2
