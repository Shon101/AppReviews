#!/bin/sh
tag=$1
if [ "$tag" == "" ]; then
	echo "No tag specified"
	exit
fi
agvtool next-version -all
git commit -a -m "Increment CFBundleVersion for $tag"
git tag -m "Tagging release $tag" -a $tag
echo "Push to origin (with tags) after release"
#git push origin master
#git push --tags
