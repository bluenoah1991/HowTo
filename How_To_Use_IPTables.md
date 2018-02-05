## How to use IPTables

### Redirect IP package *172.17.0.100:3389* to host *172.17.0.200:3389*

    sudo iptables -t nat -A POSTROUTING ! -s 172.17.0.200 -d 172.17.0.200 -p tcp  -j MASQUERADE
    sudo iptables -t nat -A PREROUTING -d 172.17.0.100 -p tcp --dport 3389 -j DNAT --to-destination 172.17.0.200:3389  

