#!/bin/bash
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y

# Install Go
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
source .bash_profile
go version

cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/v0.16.0
make build
make install
make cel-key
celestia light init

echo "Installation complete!"
celestia version




sudo tee <<EOF >/dev/null /etc/systemd/system/celd.service
[Unit]
Description=celestia-light
After=network-online.target
 
[Service]
User=$USER
ExecStart=$(which celestia) light start --core.ip rpc.celestia.pops.one --p2p.network celestia
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
 
[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable celd
sudo systemctl start celd 

echo "Check service:  sudo systemctl status celd"
echo "Check logs: sudo journalctl -u celd -f  "

