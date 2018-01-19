# Supervisor Install Guide

    sudo apt-get install python-pip
    pip --version
    sudo pip install supervisor --pre
    sudo echo_supervisord_conf > /etc/supervisord.conf

## 配置WEB控制台访问

修改supervisord.conf文件  
取消[inet\_http\_server]的注释  

    [inet_http_server]  
    port=*:9001 //通过该地址访问supervisor web控制台  

## 添加服务

按照  

    [program:theprogramname]  
    command=/your/path  

格式添加程序

## 启动服务

    /usr/local/bin/supervisord -c /etc/supervisord.conf

