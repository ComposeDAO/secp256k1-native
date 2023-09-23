#!/usr/bin/env bash

set -e

cp -r secp256k1/ secp256k1-tmp/

pushd secp256k1-tmp/

# Modify secp256k1 native code with addition of JNI support
# Files copied from removed JNI support in bitcoin-core/secp256k1 repo
# https://github.com/bitcoin-core/secp256k1/pull/682
cp ../jni/build-aux/m4/* build-aux/m4/
cp -r ../jni/java/ src/java/
cp ../jni/Makefile.am Makefile.am
cp ../jni/configure.ac configure.ac

# Compile secp256k1 native code
./autogen.sh
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CFLAGS="-I$JAVA_HOME/include -I$JAVA_HOME/include/linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CFLAGS="-I$JAVA_HOME/include -I$JAVA_HOME/include/darwin"
fi
./configure --enable-jni --enable-module-ecdh --enable-experimental --enable-module-schnorrsig --enable-module-ecdsa-adaptor CFLAGS="$CFLAGS"
make CFLAGS="-std=c99"
make
make check
