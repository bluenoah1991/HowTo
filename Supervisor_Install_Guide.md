### Supervisor Install Guide ###

>Tip: Require Python 2.7 runtime

`sudo apt-get install python-pip`  

`pip --version`  

`sudo pip install supervisor --pre`  

`sudo echo_supervisord_conf > /etc/supervisord.conf`  
这里有可能因为权限问题无法创建文件，如果出现此情况，你知道该如何处理  

修改supervisord.conf文件  
取消[inet\_http\_server]的注释  
[inet\_http\_server]  
port=*:9001 //通过该地址访问supervisor web控制台  

按照  
[program:theprogramname]  
command=/your/path  
格式添加程序

`/usr/local/bin/supervisord -c /etc/supervisord.conf`  

