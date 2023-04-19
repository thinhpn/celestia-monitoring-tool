#!/bin/bash
echo -e "====BEGIN INSTALL CELESTIA LIGHT-NODE===
- The script is used to install celestia light node version for monitoring.
- First let's intall Celestia Light Node
";
IP_ADDRESS=$(hostname -I | cut -d' ' -f1)
echo "#############===========YOUR IP ADDRESS: $IP_ADDRESS"

echo "#############===========SYSTEM UPDATE"
apt-get update -y
apt install sudo -y
apt install systemd -y

echo "#############===========INSTALL LIB, GIT & GO"
apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y
ver="1.20" 
cd $HOME 
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
rm -rf /usr/local/go 
tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 
rm "go$ver.linux-amd64.tar.gz"

echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

apt install git

echo "#############===========CLONE CELESTIA REPOSITORY & INSTALL NODE"
cd $HOME 
rm -rf celestia-node 
git clone https://github.com/celestiaorg/celestia-node.git

cd celestia-node/ 
git checkout tags/v0.9.1

make build 
make install 
make cel-key

## INIT BLOCKSPACE RACE
celestia light init --p2p.network blockspacerace

## CREATE SERVICE TO RUN NODE BY SYSTEMD
sudo tee /etc/systemd/system/celestia-lightd.service <<EOF >/dev/null
[Unit]
Description=celestia-lightd Light Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/celestia light start --core.ip https://rpc-blockspacerace.pops.one/ --keyring.accname my_celes_key --gateway --gateway.addr localhost --gateway.port 26659 --p2p.network blockspacerace --metrics.tls=false --metrics --metrics.endpoint localhost:4318
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

cat /etc/systemd/system/celestia-lightd.service
sudo systemctl enable celestia-lightd
sudo systemctl start celestia-lightd
journalctl -u celestia-lightd.service -f

## GET NODE INFORMATION
NODE_TYPE=light
AUTH_TOKEN=$(celestia $NODE_TYPE auth admin --p2p.network blockspacerace)

NODE_INFO=$(curl -X POST \
 -H "Authorization: Bearer $AUTH_TOKEN" \
 -H 'Content-Type: application/json' \
 -d '{"jsonrpc":"2.0","id":0,"method":"p2p.Info","params":[]}' \
 http://localhost:26658)

NODE_ID=$(echo "$NODE_INFO" | jq -r '.result.ID')

echo -e "\nThe celestia light-node was installed successfully!"
echo -e "\nYour light-node id: $NODE_ID"

