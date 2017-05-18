#!/usr/bin/env sh
set -x
# install charles proxy from deb sources.
# http://www.charlesproxy.com
sudo sh -c 'echo "deb http://www.charlesproxy.com/packages/apt/ charles-proxy main" > /etc/apt/sources.list.d/charles-proxy.list'
wget -q http://www.charlesproxy.com/packages/apt/PublicKey -O - | sudo apt-key add -

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y charles-proxy
# or for the brave
#sudo apt-get install -y charles-proxy-beta 
