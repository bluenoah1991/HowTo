> yarn.nodemanager.resource.memory-mb: 4096  

NodeManager 分配的资源，不能超过NodeManager节点物理内存，配置在NodeManager上

> yarn.scheduler.minimum-allocation-mb: 1024  

每个Container内存大小，配置在ResourceManager上

> yarn.scheduler.maximum-allocation-mb: 4096  

Container内存总大小，配置在ResourceManager上
