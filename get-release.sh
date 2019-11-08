#! /usr/bin/env bash

set -o errexit

mkdir -p workdir
cd workdir
mkdir -p ./bin

curl -s 'https://api.github.com/repos/aria2/aria2/releases/latest' > target.json


getlist(){
    cat target.json | jq -r .assets[].browser_download_url
}

darwin_bin=$(getlist | grep darwin.tar.bz2)
wget $darwin_bin -O a.tar.bz2
tar xvf a.tar.bz2
DIR=$(ls | grep aria2-)
( cd $DIR/bin && cp aria2c ../../bin/aria2c.darwin && cp aria2c ../../bin/aria2c.darwin.upx )
rm -rf a.tar.bz2 aria2*


win32_bin=$(getlist | grep win-32bit)
wget $win32_bin -O a.zip
unzip a.zip
( cd $(ls | grep aria) && cp aria2c.exe ../bin/aria2c.win32.exe && cp aria2c.exe ../bin/aria2c.win32.upx.exe)
rm -rf a.zip $(ls | grep aria)


win64_bin=$(getlist | grep win-64bit)
wget $win64_bin -O a.zip
unzip a.zip
( cd $(ls | grep aria) && cp aria2c.exe ../bin/aria2c.win64.exe && cp aria2c.exe ../bin/aria2c.win64.upx.exe)
rm -rf a.zip $(ls | grep aria)


arm64=$(getlist | grep aarch64)
wget $arm64 -O a.zip
unzip a.zip
( cd $(ls | grep aria) && cp aria2c ../bin/aria2c.aarch64 && cp aria2c  ../bin/aria2c.aarch64.upx )
rm -rf a.zip $(ls | grep aria)

rm target.json

( cd bin && upx $(ls | grep upx) )

# workdir/bin
