Custom ISO based on official Oracle Linux

#!/bin/sh
#Based on #http://www.smorgasbork.com/2012/01/04/building-a-custom-centos-7-kickstart-disc-part-2/
#http://www.frankreimer.de/?p=522

#Prepare workdir
mount /dev/cdrom /mnt
mkdir -p kickstart_build/all_rpms
cd kickstart_build/

#Copy resources from oficial ISO
cp -ax /mnt/Packages/* all_rpms/
cp -ax /mnt/isolinux/ .
cp -ax /mnt/images/ isolinux/
cp -ax /mnt/LiveOS/ isolinux/
cp -ax /mnt/.discinfo isolinux/
cp -ax /mnt/.treeinfo isolinux/

#modify kickstart
vim kickstart_build/isolinux/ks/ks.cfg

#validate kickstart
yum install pykickstart
ksvalidator kickstart_build/isolinux/ks/ks.cfg

#To create a crypted root password which you can use within your kickstart file do the following:
# python -c 'import crypt; print(crypt.crypt("My Password", "$6$My Salt"))'
#This generates a SHA512 crypted password.

#Import packages groups
cp -ax /mnt/repodata/*-comps-Server.xml.gz comps.xml.gz
gunzip comps.xml.gz 

#Look in the file ~kickstart_build/comps.xml This defines the packages and their groups.
#select packages for @core group
vim comps.xml 

#Determine which packages to include
#Your baseline kickstart configuration file will list the packages that are to be installed (under %packages). 
#Groups are noted with a leading @. You can edit this list, but leave @core in the file, since that group has system-critical packages in it.

#copy only packages we need
yum install perl-XML-Simple
mkdir -p isolinux/Packages
gather_packages.pl comps.xml all_rpms isolinux/Packages x86_64

#add custom packages
Cd isolinux/Packages
yum install --downloadonly --downloaddir=. ovmd xenstoreprovider python-simplejson ovm-template-config-authentication ovm-template-config-datetime ovm-template-config-network ovm-template-config-system


#resolve dependencies and copy to rpm store
resolve_deps.pl all_rpms isolinux/Packages x86_64

#Test dependencies
cd isolinux/Packages
mkdir /tmp/testdb
rpm --initdb --dbpath /tmp/testdb
rpm --test --dbpath /tmp/testdb -Uvh *.rpm

#Resolve dependencies. Copy necessary rpms and it's dependencies to Packages

#Build repo
~# yum install createrepo deltarpm python-deltarpm
~# cd isolinux
~# createrepo -g ../comps.xml . 
~# cd ..

#build iso
~# yum install genisoimage
~# chmod 664 isolinux/isolinux.bin
~# mkisofs -o ../OL74-min.iso -b isolinux.bin -c boot.cat -no-emul-boot -V 'OL-7.4 Server.x86_64' -boot-load-size 4 -boot-info-table -R -J -v -T isolinux/

#Test ISO
#When the system (virtual or physical) boots up, you’ll see your standard CentOS installation #prompt. Before the countdown expires, hit ESC and type
#linux inst.ks=cdrom:/dev/cdrom:/ks/ks.cfg

#Create menu
~# vim isolinux/isolinux.cfg #and change menu names to eg:
label linuxovm
  append initrd=initrd.img inst.stage2=hd:LABEL=OL-7.4\x20Server.x86_64 inst.ks=hd:LABEL=OL-7.4\x20Server.x86_64:/ks/ovm.ks

