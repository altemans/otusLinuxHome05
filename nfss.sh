yum install nfs-utils -y
systemctl enable firewalld --now
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent
firewall-cmd --reload
systemctl enable nfs --now
echo `ss -tnplu | grep -E '2049|20048|111'`

mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
echo '/srv/share 192.168.50.11/32(rw,sync,root_squash)' | tee -a /etc/exports
exportfs -r
echo `exportfs -s`
touch /srv/share/upload/check_file
echo 'test' >> /srv/share/upload/check_file