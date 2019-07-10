# Shadowsocks over V2Ray

Run **shadowsocks_systemd_install.sh** on the server.

	$ sudo ./shadowsocks_systemd_install.sh

Copy required files to local.

	C:\src\ss-local>scp root@1.2.3.4:/path/to/v2ray-plugin_linux_amd64 .
	C:\src\ss-local>scp root@1.2.3.4:/etc/shadowsocks-client.json .
	C:\src\ss-local>scp root@1.2.3.4:/root/server.crt .

Update the server address in the shadowsocks.json file to the real server.

	{
	    "server": "1.2.3.4",
	    "server_port": 443,
	    "local_address": "0.0.0.0",
	    "local_port": 1080,
	    "password": "123456",
	    "timeout": 300,
	    "method": "aes-256-gcm",
	    "fast_open": false,
	    "plugin": "/usr/bin/v2ray-plugin_linux_amd64",
	    "plugin_opts": "tls;host=mydomain.me;cert=/root/server.crt"
	}

Build docker images

	C:\src\ss-local>docker build -t image_name .

Run docker

	C:\src\ss-local>docker run -p 1080:1080 -p 8118:8118 --name container_name image_name

Requirement shadowsocks-libev 3.2.5+

> https://github.com/shadowsocks/v2ray-plugin/issues/29#issuecomment-468924920
