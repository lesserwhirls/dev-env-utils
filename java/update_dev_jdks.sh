#!/bin/bash

declare -a JDK_VERSIONS=("8" "11" "17")

TGZ=tmp.tar.gz
BASE_DEST=/usr/local/jdk
CORRETTO_URL="https://corretto.aws/downloads/latest"
TEMURIN_URL="https://api.adoptium.net/v3/binary/latest"

PROFILE_FILE=jdks.sh

unpack_and_update () {
    mkdir ${DEST}_TMP
    tar xf ${TGZ} --strip-components=1 -C ${DEST}_TMP
    rm -rf ${DEST}
    mv ${DEST}_TMP ${DEST}
    rm ${TGZ}
}

# update amazon corretto and eclipse temurin JDKs
for VERSION in ${JDK_VERSIONS[@]}; do
    DEST=${BASE_DEST}/corretto/${VERSION}
    CORRETTO_PATH=amazon-corretto-${VERSION}-x64-linux-jdk.tar.gz
    mkdir -p ${DEST}
    curl -L -X GET ${CORRETTO_URL}/${CORRETTO_PATH} -o ${TGZ}
    unpack_and_update
    echo "export CORRETTO_${VERSION}_JDK=${BASE_DEST}/corretto/${VERSION}" >> ${PROFILE_FILE}

    DEST=${BASE_DEST}/temurin/${VERSION}
    TEMURIN_PATH=${VERSION}/ga/linux/x64/jdk/hotspot/normal/eclipse
    mkdir -p ${DEST}
    curl -L -X GET ${TEMURIN_URL}/${TEMURIN_PATH}?project=jdk \
        -o ${TGZ}
    unpack_and_update
    echo "export TEMURIN_${VERSION}_JDK=${BASE_DEST}/temurin/${VERSION}" >> ${PROFILE_FILE}
done

mv ${PROFILE_FILE} /etc/profile.d/${PROFILE_FILE}

