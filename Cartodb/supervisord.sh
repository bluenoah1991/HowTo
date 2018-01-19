#!/bin/bash

/etc/init.d/redis-server restart
/etc/init.d/postgresql restart
setsid bundle exec script/resque > /dev/null 2>&1 &
bundle exec rails s -p 3000
