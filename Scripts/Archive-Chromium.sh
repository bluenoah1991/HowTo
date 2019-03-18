#!/bin/bash

git add .
git commit -m "TEMP"

VersionString=''

if [ -e ./chrome/VERSION ]; then
while IFS='=' read -r name val
do
if [ -z $VersionString ]; then
VersionString="$val"
else
VersionString="$VersionString.$val"
fi
done < ./chrome/VERSION
fi

if [ -z $VersionString ]; then
VersionString='UnknownVersion'
fi

git archive -o ../Archive-$VersionString-$(date '+%Y%m%d%H%M%S').zip HEAD \
	$(git diff --name-only HEAD~1)
git reset --mixed HEAD~1