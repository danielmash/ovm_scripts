#!/bin/bash

OVMCLI="ssh -p 10000 admin@localhost"
TPL_NAME=test-template
VM_NAME=test-vm
PASSWD=2Hard4You
SERVER_POOL=MY_POOL
ORACLE_HOST=vms-001
REPO_NAME=${ORACLE_HOST}-ssd
NETWORK_NAME=101
IPADDR=192.168.100.249
NETMASK=255.255.255.0
GATEWAY=192.168.100.1
DNS_SERVERS=192.168.100.1
DNS_SEARCH_DOMAINS="mydomain.net"
PARTITION_DEVICE="/dev/xvdb"
PARTITION_NAME="u01"
SPACEWALK_SERVER="space-001.local"
SPACEWALK_ACTIVATIONKEY="1-oracle-7-latest"

#$OVMCLI ""

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
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.dns-servers.0 message=${DNS_SERVERS} log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.network.dns-search-domains.0 message=${DNS_SEARCH_DOMAINS} log=no"

#Partitioning test
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.mycompany.linux.partition.device.0 message=${PARTITION_DEVICE} log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.mycompany.linux.partition.name.0 message=${PARTITION_NAME} log=no"

#Spacewalk
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.mycompany.linux.spacewalk.server message=${SPACEWALK_SERVER} log=no"
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.mycompany.linux.spacewalk.activationkey message=${SPACEWALK_ACTIVATIONKEY} log=no"

# Assign root password, which triggers previous params to be loaded immediately
$OVMCLI "sendVmMessage Vm name=${VM_NAME} key=com.oracle.linux.root-password message=${PASSWD} log=no"

# Test template configuration scripts by triggering manually; run this command on the VM - not required for regular build 
# ovmd -l | ovm-template-config -s authentication --stdin configure
