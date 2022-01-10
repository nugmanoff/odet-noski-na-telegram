#!/bin/sh
YELLOW='\033[1;33m'
NC='\033[0m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
sudo apt update
sudo apt install dante-server
sudo rm /etc/danted.conf
echo "${YELLOW}Введите имя пользователя для proxy:${NC}"
read username
echo "${YELLOW}Введите пароль для proxy:${NC}"
read password
cfg=$(cat <<EOF
logoutput: syslog
user.privileged: root
user.unprivileged: nobody

# The listening network interface or address.
internal: 0.0.0.0 port=3784

# The proxying network interface or address.
external: eth0

# socks-rules determine what is proxied through the external interface.
socksmethod: username

# client-rules determine who can connect to the internal interface.
clientmethod: none

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}
EOF
)
sudo echo  "$cfg" > /etc/danted.conf
sudo useradd -r -s /bin/false "$username"
echo "$username:$password" | chpasswd
sudo systemctl restart danted.service
ip=$(curl ifconfig.me)
echo "${GREEN}Для использования прокси откройте следующий URL:${LIGHT_BLUE} tg://socks?server=$ip&port=3784&user=$username&pass=$password ${NC}"