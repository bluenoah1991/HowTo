# Spark开发 #
### 1 启动程序 ###

>TIP: 以下文档基于Spark On Yarn部署方式

Spark有2种启动方式  
1) 命令行交互方式  
`${SPARK_HOME}/bin/spark-shell --master yarn-client`  
2) 提交JAR文件  
`${SPARK_HOME}/bin/spark-submit --class path.to.your.Class --master yarn-cluster [options] <app jar> [app options]`  
>注意--jars参数用逗号分隔，不支持换行  
>jar包路径和classpath路径支持hdfs://架构，实际部署过程中建议首先将jar包及依赖包预拷贝到分布式文件系统中  

[http://colobu.com/2014/12/09/spark-submitting-applications/](http://colobu.com/2014/12/09/spark-submitting-applications/ "提交Spark程序")

### 2 构建Spark程序 ###

建议由Scala编写Spark程序，Scala与Java交互良好

Java与Scala之间的容器转换参考  
[http://alvinalexander.com/scala/how-to-convert-maps-scala-java](http://alvinalexander.com/scala/how-to-convert-maps-scala-java "How to convert maps scala java")  
>import scala.collection.JavaConversions._

### 3 SBT ###

sbt构建工具用于构建scala程序  

对应于Maven的pom.xml文件，sbt需要编写build.sbt文件  
[http://www.scala-sbt.org/0.13/tutorial/Bare-Def.html](http://www.scala-sbt.org/0.13/tutorial/Bare-Def.html "build.sbt")  

sbt默认基于ivy包管理，填写到build.sbt中的公共jar包会通过ivy进行下载，并保存到  
`/root/.ivy2/jars/`或者`/home/yourusername/.ivy2/jars/`中  

本地jar包，请放入`${YOUR_SOLUTION_HOME}/lib/`中  

>sbt拥有与maven类似的目录结构  
>[http://www.scala-sbt.org/0.13/tutorial/Directories.html](http://www.scala-sbt.org/0.13/tutorial/Directories.html)  

### 4 Debug ###

Scala在linux下暂时没有良好的调试工具，可以通过打开spark的日志功能
`cp ${SPARK_HOME}/log4j.properties.template ${SPARK_HOME}/log4j.properties`  
一般调试，不需要修改log4j.properties中的配置  

**基于jdb的断点调试**  

Spark应用程序启动后，共计会有3类进程  
1. Driver进程  
2. Application Master进程  
3. Executor进程  

你的应用程序*一般情况下*会运行在Executor进程中，通过为spark-submit命令添加  
`--conf "spark.executor.extraJavaOptions=-XXX"`  
为executor虚拟机进程开启调试功能  
Spark启动后，通过Spark UI，查看Executor所在节点，并通过jdb -sourcepath */your/path* -attach *jdb_port*进行调试
