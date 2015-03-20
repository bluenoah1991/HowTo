#!/bin/bash

if [ $# > 0 ]; then
  fileName=$1
  rm /var/lib/tomcat7/work/Catalina/ -rf
  rm /var/lib/tomcat7/webapps/${fileName} -rf
  rm /var/lib/tomcat7/webapps/${fileName%.war*} -rf
  cp ${fileName} /var/lib/tomcat7/webapps/${fileName}
  /usr/share/tomcat7/bin/catalina.sh stop
  /usr/share/tomcat7/bin/catalina.sh jpda start
else
  echo "miss parameters"
fi

