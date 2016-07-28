#!/bin/sh

conf=${CONFIGURATION} # Use for release only: if [ $conf == "Release"]
arch=${ARCHS:0:4}

PlistBuddy=/usr/libexec/PlistBuddy
WORKINGDIR=`pwd`
echo Runnning buildscript from directory $WORKINGDIR

cd ./platforms/ios
mainPListPath=./${PRODUCT_NAME}/${PRODUCT_NAME}-Info.plist

currentBundleVersion=`$PlistBuddy -c "Print :CFBundleVersion" "$mainPListPath"`
echo current CFBundleVersion: "$currentBundleVersion"

incrementedBundleVersion=`$PlistBuddy -c "Print CFBundleVersion" "$mainPListPath" | /usr/bin/perl -pe 's/(\d+\.\d+\.\d+\.)(\d+)/$1.($2+1)/eg'`
echo CFBundleVersion to be updated to: "$incrementedBundleVersion\n"

for plistFilePath in **/*Info.plist; do
	echo "Now Processing Plist file: $plistFilePath ..."
	bundleVersion=`$PlistBuddy -c "Print :CFBundleVersion" "$plistFilePath" 2>/dev/null`
	exitCode=$?
	
	if ((exitCode == 0)); then	
		echo Bumping version ...
		`$PlistBuddy -c "Set :CFBundleVersion $incrementedBundleVersion" "$plistFilePath" 2>/dev/null`
		bumpVersionExitCode=$?
		newBundleVersion=`$PlistBuddy -c "Print :CFBundleVersion" "$plistFilePath" 2>/dev/null`		
		
		if ((bumpVersionExitCode == 0)); then
			echo CFBundleVersion in "$plistFilePath" bumped to: "$newBundleVersion\n"
		else
			echo Failed to bump CFBundleVersion in "$plistFilePath"
		fi
			
	else
		echo "$plistFilePath has no CFBundleVersion to bump, skipping .. "
	fi
done

echo "\nUpdating Cordova config file now ..\n"
cd $WORKINGDIR
python increment_cordova_buildnumber.py

echo "\nAll Done! Smooth sailing!\n"




