#!/bin/bash

read -p "Username: " U
read -s -p "Password: " P

echo ""

export http_proxy="http://$U:$P@bmiproxyp.chmcres.cchmc.org:80"
export https_proxy="http://$U:$P@bmiproxyp.chmcres.cchmc.org:80"
export HTTP_PROXY="http://$U:$P@bmiproxyp.chmcres.cchmc.org:80"
export ALL_PROXY="http://$U:$P@bmiproxyp.chmcres.cchmc.org:80"
# export socks_proxy="socks5://$U:$P@bmiproxyp.chmcres.cchmc.org:1080/"
export no_proxy=localhost,127.0.0.1,bmiclustersvcp1

