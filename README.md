# Home05

<details>
  <summary>Ручное выполнение, для отладки</summary>

Во время проверки выполнения команд по методичке наткнулся на проблему - клиент не мог достучаться до сервера. Потупил, увидел, что при добавлении в /etc/fstab указан неверный адрес, поправил - все отработало.

```

sudo -i
yum install nfs-utils -y
...
Running transaction
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                     1/2 
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                       2/2 
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                     1/2 
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                       2/2 

Updated:
  nfs-utils.x86_64 1:1.3.0-0.68.el7.2                                                                                                                                                      

Complete!


[root@nfss ~]# systemctl enable firewalld --now
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.

[root@nfss ~]# firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent 
success
[root@nfss ~]# firewall-cmd --reload
success
[root@nfss ~]# systemctl enable nfs --now
Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.

[root@nfss ~]# ss -tnplu | grep -E '2049|20048|111'
udp    UNCONN     0      0         *:20048                 *:*                   users:(("rpc.mountd",pid=3616,fd=7))
udp    UNCONN     0      0         *:111                   *:*                   users:(("rpcbind",pid=338,fd=6))
udp    UNCONN     0      0         *:2049                  *:*                  
udp    UNCONN     0      0      [::]:20048              [::]:*                   users:(("rpc.mountd",pid=3616,fd=9))
udp    UNCONN     0      0      [::]:111                [::]:*                   users:(("rpcbind",pid=338,fd=9))
udp    UNCONN     0      0      [::]:2049               [::]:*                  
tcp    LISTEN     0      128       *:111                   *:*                   users:(("rpcbind",pid=338,fd=8))
tcp    LISTEN     0      128       *:20048                 *:*                   users:(("rpc.mountd",pid=3616,fd=8))
tcp    LISTEN     0      64        *:2049                  *:*                  
tcp    LISTEN     0      128    [::]:111                [::]:*                   users:(("rpcbind",pid=338,fd=11))
tcp    LISTEN     0      128    [::]:20048              [::]:*                   users:(("rpc.mountd",pid=3616,fd=10))
tcp    LISTEN     0      64     [::]:2049               [::]:*                  

[root@nfss ~]# mkdir -p /srv/share/upload 
[root@nfss ~]# chown -R nfsnobody:nfsnobody /srv/share
[root@nfss ~]# chmod 0777 /srv/share/upload

[root@nfss ~]# cat << EOF > /etc/exports
> /srv/share 192.168.50.11/32(rw,sync,root_squash)
> EOF

[root@nfss ~]# exportfs -r
[root@nfss ~]# exportfs -s 
/srv/share  192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)




altemans@Home01:~/otus/home05$ vagrant ssh nfsc
[vagrant@nfsc ~]$ sudo -i
[root@nfsc ~]# yum install nfs-utils -y
...
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                     1/2 
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                       2/2 
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                                                                                                                                     1/2 
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                                                                       2/2 

Updated:
  nfs-utils.x86_64 1:1.3.0-0.68.el7.2                                                                                                                                                      

Complete!
[root@nfsc ~]# systemctl enable firewalld --now
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
[root@nfsc ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2023-04-18 22:02:53 UTC; 7s ago

[root@nfsc ~]# echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
[root@nfsc ~]# systemctl daemon-reload
[root@nfsc ~]# systemctl restart remote-fs.target
[root@nfsc ~]# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=46,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=27204)
192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=tcp,local_lock=none,addr=192.168.50.10)

[root@nfsc ~]# ls /mnt/upload/
check_file

```

</details>

### Описание скрипта

<details>
  <summary>Описание скрипта</summary>

Скрипт nfss.sh - ставит nfs-utils включает файрвол, шарит папку, промежуточно выводит эхо команд
Скрипт nfsc.sh - ставит nfs-utils монтирует папку, добавляет в /etc/fstab, далее ожидает появление файла в шаре. Когда файл появляется - выводит его содержимое (test)

</details>


### Выполнение vsgrant up со скриптами

<details>
  <summary>Выполнение vsgrant up со скриптами</summary>

```

altemans@Home01:~/otus/home05$ vagrant up
Bringing machine 'nfss' up with 'virtualbox' provider...
Bringing machine 'nfsc' up with 'virtualbox' provider...
==> nfss: Importing base box 'centos/7'...
==> nfss: Matching MAC address for NAT networking...
==> nfss: Setting the name of the VM: home05_nfss_1681859870962_6125
==> nfss: Fixed port collision for 22 => 2222. Now on port 2200.
==> nfss: Clearing any previously set network interfaces...
==> nfss: Preparing network interfaces based on configuration...
    nfss: Adapter 1: nat
    nfss: Adapter 2: intnet
==> nfss: Forwarding ports...
    nfss: 22 (guest) => 2200 (host) (adapter 1)
==> nfss: Running 'pre-boot' VM customizations...
==> nfss: Booting VM...
==> nfss: Waiting for machine to boot. This may take a few minutes...
    nfss: SSH address: 127.0.0.1:2200
    nfss: SSH username: vagrant
    nfss: SSH auth method: private key
    nfss: 
    nfss: Vagrant insecure key detected. Vagrant will automatically replace
    nfss: this with a newly generated keypair for better security.
    nfss: 
    nfss: Inserting generated public key within guest...
    nfss: Removing insecure key from the guest if it's present...
    nfss: Key inserted! Disconnecting and reconnecting using new SSH key...
==> nfss: Machine booted and ready!
==> nfss: Checking for guest additions in VM...
    nfss: No guest additions were detected on the base box for this VM! Guest
    nfss: additions are required for forwarded ports, shared folders, host only
    nfss: networking, and more. If SSH fails on this machine, please install
    nfss: the guest additions and repackage the box to continue.
    nfss: 
    nfss: This is not an error message; everything may continue to work properly,
    nfss: in which case you may ignore this message.
==> nfss: Setting hostname...
==> nfss: Configuring and enabling network interfaces...
==> nfss: Rsyncing folder: /home/altemans/otus/home05/ => /vagrant
==> nfss: Running provisioner: shell...
    nfss: Running: /tmp/vagrant-shell20230419-4358-19k85rd.sh
    nfss: Loaded plugins: fastestmirror
    nfss: Determining fastest mirrors
    nfss:  * base: ftp.nluug.nl
    nfss:  * extras: mirror.mijn.host
    nfss:  * updates: mirror.ams1.nl.leaseweb.net
    nfss: Resolving Dependencies
    nfss: --> Running transaction check
    nfss: ---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
    nfss: ---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
    nfss: --> Finished Dependency Resolution
    nfss: 
    nfss: Dependencies Resolved
    nfss: 
    nfss: ================================================================================
    nfss:  Package          Arch          Version                    Repository      Size
    nfss: ================================================================================
    nfss: Updating:
    nfss:  nfs-utils        x86_64        1:1.3.0-0.68.el7.2         updates        413 k
    nfss: 
    nfss: Transaction Summary
    nfss: ================================================================================
    nfss: Upgrade  1 Package
    nfss: 
    nfss: Total download size: 413 k
    nfss: Downloading packages:
    nfss: No Presto metadata available for updates
    nfss: Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
    nfss: warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    nfss: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfss: Importing GPG key 0xF4A80EB5:
    nfss:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    nfss:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    nfss:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    nfss:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfss: Running transaction check
    nfss: Running transaction test
    nfss: Transaction test succeeded
    nfss: Running transaction
    nfss:   Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfss:   Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfss:   Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfss:   Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfss: 
    nfss: Updated:
    nfss:   nfs-utils.x86_64 1:1.3.0-0.68.el7.2
    nfss: 
    nfss: Complete!
    nfss: Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
    nfss: Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
    nfss: success
    nfss: success
    nfss: Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
    nfss: udp UNCONN 0 0 *:2049 *:* udp UNCONN 0 0 *:20048 *:* users:(("rpc.mountd",pid=3650,fd=7)) udp UNCONN 0 0 *:111 *:* users:(("rpcbind",pid=341,fd=6)) udp UNCONN 0 0 [::]:2049 [::]:* udp UNCONN 0 0 [::]:20048 [::]:* users:(("rpc.mountd",pid=3650,fd=9)) udp UNCONN 0 0 [::]:111 [::]:* users:(("rpcbind",pid=341,fd=9)) tcp LISTEN 0 64 *:2049 *:* tcp LISTEN 0 128 *:111 *:* users:(("rpcbind",pid=341,fd=8)) tcp LISTEN 0 128 *:20048 *:* users:(("rpc.mountd",pid=3650,fd=8)) tcp LISTEN 0 64 [::]:2049 [::]:* tcp LISTEN 0 128 [::]:111 [::]:* users:(("rpcbind",pid=341,fd=11)) tcp LISTEN 0 128 [::]:20048 [::]:* users:(("rpc.mountd",pid=3650,fd=10))
    nfss: /srv/share 192.168.50.11/32(rw,sync,root_squash)
    nfss: /srv/share 192.168.50.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
==> nfsc: Importing base box 'centos/7'...
==> nfsc: Matching MAC address for NAT networking...
==> nfsc: Setting the name of the VM: home05_nfsc_1681859955233_52229
==> nfsc: Clearing any previously set network interfaces...
==> nfsc: Preparing network interfaces based on configuration...
    nfsc: Adapter 1: nat
    nfsc: Adapter 2: intnet
==> nfsc: Forwarding ports...
    nfsc: 22 (guest) => 2222 (host) (adapter 1)
==> nfsc: Running 'pre-boot' VM customizations...
==> nfsc: Booting VM...
==> nfsc: Waiting for machine to boot. This may take a few minutes...
    nfsc: SSH address: 127.0.0.1:2222
    nfsc: SSH username: vagrant
    nfsc: SSH auth method: private key
    nfsc: 
    nfsc: Vagrant insecure key detected. Vagrant will automatically replace
    nfsc: this with a newly generated keypair for better security.
    nfsc: 
    nfsc: Inserting generated public key within guest...
    nfsc: Removing insecure key from the guest if it's present...
    nfsc: Key inserted! Disconnecting and reconnecting using new SSH key...
==> nfsc: Machine booted and ready!
==> nfsc: Checking for guest additions in VM...
    nfsc: No guest additions were detected on the base box for this VM! Guest
    nfsc: additions are required for forwarded ports, shared folders, host only
    nfsc: networking, and more. If SSH fails on this machine, please install
    nfsc: the guest additions and repackage the box to continue.
    nfsc: 
    nfsc: This is not an error message; everything may continue to work properly,
    nfsc: in which case you may ignore this message.
==> nfsc: Setting hostname...
==> nfsc: Configuring and enabling network interfaces...
==> nfsc: Rsyncing folder: /home/altemans/otus/home05/ => /vagrant
==> nfsc: Running provisioner: shell...
    nfsc: Running: /tmp/vagrant-shell20230419-4358-1gxp46w.sh
    nfsc: Loaded plugins: fastestmirror
    nfsc: Determining fastest mirrors
    nfsc:  * base: mirror.proserve.nl
    nfsc:  * extras: ftp.nluug.nl
    nfsc:  * updates: mirror.nforce.com
    nfsc: Resolving Dependencies
    nfsc: --> Running transaction check
    nfsc: ---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
    nfsc: ---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
    nfsc: --> Finished Dependency Resolution
    nfsc: 
    nfsc: Dependencies Resolved
    nfsc: 
    nfsc: ================================================================================
    nfsc:  Package          Arch          Version                    Repository      Size
    nfsc: ================================================================================
    nfsc: Updating:
    nfsc:  nfs-utils        x86_64        1:1.3.0-0.68.el7.2         updates        413 k
    nfsc: 
    nfsc: Transaction Summary
    nfsc: ================================================================================
    nfsc: Upgrade  1 Package
    nfsc: 
    nfsc: Total download size: 413 k
    nfsc: Downloading packages:
    nfsc: No Presto metadata available for updates
    nfsc: Public key for nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm is not installed
    nfsc: warning: /var/cache/yum/x86_64/7/updates/packages/nfs-utils-1.3.0-0.68.el7.2.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    nfsc: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfsc: Importing GPG key 0xF4A80EB5:
    nfsc:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    nfsc:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    nfsc:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    nfsc:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    nfsc: Running transaction check
    nfsc: Running transaction test
    nfsc: Transaction test succeeded
    nfsc: Running transaction
    nfsc:   Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfsc:   Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfsc:   Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64                          1/2
    nfsc:   Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                            2/2
    nfsc: 
    nfsc: Updated:
    nfsc:   nfs-utils.x86_64 1:1.3.0-0.68.el7.2
    nfsc: 
    nfsc: Complete!
    nfsc: Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
    nfsc: Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
    nfsc: ● firewalld.service - firewalld - dynamic firewall daemon
    nfsc:    Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
    nfsc:    Active: active (running) since Tue 2023-04-18 23:20:26 UTC; 41ms ago
    nfsc:      Docs: man:firewalld(1)
    nfsc:  Main PID: 3503 (firewalld)
    nfsc:    CGroup: /system.slice/firewalld.service
    nfsc:            ├─3503 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
    nfsc:            └─3505 /usr/sbin/iptables -w -L -n
    nfsc: 
    nfsc: Apr 18 23:20:25 nfsc systemd[1]: Starting firewalld - dynamic firewall daemon...
    nfsc: Apr 18 23:20:26 nfsc systemd[1]: Started firewalld - dynamic firewall daemon.
    nfsc: ● firewalld.service - firewalld - dynamic firewall daemon Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled) Active: active (running) since Tue 2023-04-18 23:20:26 UTC; 72ms ago Docs: man:firewalld(1) Main PID: 3503 (firewalld) CGroup: /system.slice/firewalld.service ├─3503 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid └─3505 /usr/sbin/iptables -w -L -n Apr 18 23:20:25 nfsc systemd[1]: Starting firewalld - dynamic firewall daemon... Apr 18 23:20:26 nfsc systemd[1]: Started firewalld - dynamic firewall daemon.
    nfsc: 192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0
    nfsc: systemd-1 on /mnt type autofs (rw,relatime,fd=46,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=26464)
    nfsc: check_file
    nfsc: test
```
</details>
