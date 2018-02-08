#!/bin/bash

OVMCLI="ssh -p 10000 admin@localhost"
TPL_NAME="test-template-1"
VM_NAME="test-tplvm-1"
VM_OSTYPE="Oracle Linux 7"
VM_MEM="2048"
VM_CPU="2"
SERVER_POOL="MY_POOL"
ORACLE_HOST="vms-001"
REPO_NAME="${ORACLE_HOST}-ssd"
NETWORK_NAME="100"
TPL_REPO="nas"
ISO_FILE="my-OL74-auto.iso"
ISO_URL="http://192.168.44.234/pub/${ISO_FILE}"

#generate ISO

#$OVMCLI "importVirtualCdrom Repository name=${ISO_REPO} url=${ISO_URL}"

#Create Vm
$OVMCLI "create Vm name=${VM_NAME} osType='${VM_OSTYPE}' repository=${REPO_NAME} memory=${VM_MEM} memoryLimit=${VM_MEM} cpuCount=${VM_CPU} bootOrder='CDROM,DISK' domainType=XEN_HVM_PV_DRIVERS on ServerPool name=${SERVER_POOL}"
$OVMCLI "create VirtualDisk name=${VM_NAME}_xvda size=30 sparse=yes shareable=No on Repository name=${REPO_NAME}"
$OVMCLI "create VmDiskMapping slot=0 virtualDisk=${VM_NAME}_xvda name=${VM_NAME}_OS on Vm name=${VM_NAME}"
$OVMCLI "create VmDiskMapping slot=1 virtualCd=${ISO_FILE} name=${VM_NAME}_CDROM on Vm name=${VM_NAME}"
$OVMCLI "create Vnic name=${VM_NAME}_eth0 network=vlan_${NETWORK_NAME} on Vm name=${VM_NAME}"

# Start the VM
$OVMCLI "start Vm name=${VM_NAME}"
#Manually choose ks install in vm console

echo -n "Please choose kickstart from vm console and wait until os installed."
while `$OVMCLI "show Vm name=${VM_NAME}" | grep -q 'Status = Running'`; do echo -n ".";sleep 1; done; echo

#Clone vm to template (Temporary Vm and its customizer)
$OVMCLI "delete VmCloneCustomizer name=clone_customizer"
$OVMCLI "create VmCloneCustomizer name=clone_customizer on Vm name=${VM_NAME}"
$OVMCLI "create VmCloneNetworkMapping name=${NETWORK_NAME} network=vlan_${NETWORK_NAME} vnic=${VM_NAME}_eth0 on VmCloneCustomizer name=clone_customizer"
$OVMCLI "create VmCloneStorageMapping name=${VM_NAME}_OS cloneType=SPARSE_COPY vmDiskMapping=${VM_NAME}_OS repository=${TPL_REPO} on VmCloneCustomizer name=clone_customizer"
$OVMCLI "clone Vm name=${VM_NAME} destType=VmTemplate destName=${TPL_NAME} serverPool=${SERVER_POOL} cloneCustomizer=clone_customizer targetRepository=${TPL_REPO}"

# Delete template VM
$OVMCLI "delete VmDiskMapping name=${VM_NAME}_OS"
$OVMCLI "delete VmDiskMapping name=${VM_NAME}_CDROM"
$OVMCLI "delete VirtualDisk name=${VM_NAME}_xvda"
$OVMCLI "delete Vnic name=${VM_NAME}_eth0"
$OVMCLI "delete VmCloneCustomizer name=clone_customizer"
$OVMCLI "delete Vm name=${VM_NAME}"

#Create Template Customizer (Permanent one: for cloning vm from this template)
$OVMCLI "delete VmCloneCustomizer name=${REPO_NAME}_vlan_${NETWORK_NAME}"
$OVMCLI "create VmCloneCustomizer name=${REPO_NAME}_vlan_${NETWORK_NAME} on Vm name=${TPL_NAME}"
$OVMCLI "create VmCloneNetworkMapping name=${TPL_NAME}_eth0 network=vlan_${NETWORK_NAME} vnic=${TPL_NAME}_eth0 on VmCloneCustomizer name=${REPO_NAME}_vlan_${NETWORK_NAME}"
$OVMCLI "create VmCloneStorageMapping name=${TPL_NAME}_OS cloneType=SPARSE_COPY vmDiskMapping=${TPL_NAME}_OS repository=${REPO_NAME} on VmCloneCustomizer name=${REPO_NAME}_vlan_${NETWORK_NAME}"
