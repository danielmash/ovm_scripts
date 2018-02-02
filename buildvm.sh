#!/bin/bash

OVMCLI="ssh -p 10000 admin@localhost"
TPL_NAME=mytemplate
VM_NAME=myvm
PASSWD=2Hard4U
SERVER_POOL=MY_POOL
ORACLE_HOST=ovs-001
REPO_NAME=${ORACLE_HOST}-REPO
NETWORK_NAME=230
IPADDR=10.240.23.251
NETMASK=255.255.255.0
GATEWAY=10.240.23.1

#$OVMCLI ""
#$OVMCLI --list

# Clone the template
#$OVMCLI "clone Vm name=${TPL_NAME} destType=Vm destName=${VM_NAME} serverPool=${SERVER_POOL}"

# Clone the template using Clone customizer
$OVMCLI "clone Vm name=${TPL_NAME} destType=Vm destName=${VM_NAME} serverPool=${SERVER_POOL} cloneCustomizer=${ORACLE_HOST}_${NETWORK_NAME} targetRepository=${REPO_NAME}"

# Start the VM
$OVMCLI "start Vm name=${VM_NAME}"

# Configure the network
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.hostname message=${VM_NAME} log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.device.0 message=eth0 log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.onboot.0 message=yes log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.bootproto.0 message=static log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.ipaddr.0 message=${IPADDR} log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.netmask.0 message=${NETMASK} log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.gateway.0 message=${GATEWAY} log=no"


# Assign root password, which triggers previous params to be loaded immediately
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.root-password message=${PASSWD} log=no"


# Test template configuration scripts by triggering manually; run this command on the VM - not required for regular build 
# ovmd -l | ovm-template-config -s authentication --stdin configure
