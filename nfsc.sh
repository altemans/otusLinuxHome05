yum install nfs-utils -y
systemctl enable firewalld --now
systemctl status firewalld
echo `systemctl status firewalld`
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" | tee -a /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
echo `mount | grep mnt`
echo `ls /mnt/upload/`
while [ ! -f "/mnt/upload/check_file" ]
do
    sleep 1s
done
echo `cat /mnt/upload/check_file`
