echo "
sudo umount -l "$(dirname "$0")" &&
sudo mount -o uid=1000,gid=1000,umask=0000 -L PEARL /mnt &&
/mnt/instalee/instalee --noexec work" >/tmp/remount.sh
exec sh /tmp/remount.sh
