#!/bin/bash
source vars
test -z ${KEY} && { echo "KEY variable is not defined."; exit 1; }
test -z $1 || HOST="_$1"
test -z $2 || INSTANCE="_$2"

sudo rm -f conf/keys/* conf/ccd/*

test -f ~/secrets.tar.gz.enc || curl -o ~/secrets.tar.gz.enc "https://${CLOUD_SERVER}/s/${KEY}/download?path=%2F&files=secrets.tar.gz.enc"
openssl enc -aes-256-cbc -d -in ~/secrets.tar.gz.enc | sudo tar -zxv --strip 2 secrets/docker-OpenVPN-server-stack${HOST}${INSTANCE}/conf/keys

mkdir -p conf/ccd
rm -rf ~/config
git clone https://${GIT_SERVER}/yohan/config.git ~/config
sudo cp -a ~/config/docker-OpenVPN-server-stack${HOST}${INSTANCE}/server.conf ./
sudo cp -a ~/config/docker-OpenVPN-server-stack${HOST}${INSTANCE}/ccd/* conf/ccd/
rm -rf ~/config
sudo chown -R root. conf server.conf

# --force-recreate is used to recreate container when crontab file has changed
unset VERSION_OPENVPN_SERVER
export VERSION_OPENVPN_SERVER=$(git ls-remote https://${GIT_SERVER}/yohan/docker-OpenVPN-server.git| head -1 | cut -f 1|cut -c -10)

mkdir -p ~/build
git clone https://git.scimetis.net/yohan/docker-OpenVPN-server.git ~/build/docker-OpenVPN-server
sudo docker build -t openvpn-server:$VERSION_OPENVPN_SERVER ~/build/docker-OpenVPN-server

sudo -E bash -c 'docker-compose up -d --force-recreate'

rm -rf ~/build
