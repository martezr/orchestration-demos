#!/bin/sh

set -ex

apk add libressl
apk add open-vm-tools
rc-update add open-vm-tools
/etc/init.d/open-vm-tools start

cat >/usr/local/bin/shutdown <<EOF
#!/bin/sh
poweroff
EOF
chmod +x /usr/local/bin/shutdown

sed -i "/#PermitRootLogin/c\PermitRootLogin yes" /etc/ssh/sshd_config
mkdir ~/.ssh
/etc/init.d/sshd restart
