#!/bin/bash

build_image() {
    echo $@ ;
    IMG=$1; TAG=$2; FILE=$3; shift 3; VER=`date +%Y.%m%d`;
    BASE_NAMESPACE="${NAMESPACE:-qpod}";
    docker build --squash --compress --force-rm=true -t "${BASE_NAMESPACE}/${IMG}:${TAG}" -f "$FILE" --build-arg "BASE_NAMESPACE=${BASE_NAMESPACE}" "$@" "$(dirname $FILE)" ;
    docker tag "${BASE_NAMESPACE}/${IMG}:${TAG}" "${BASE_NAMESPACE}/${IMG}:${VER}" ;
}

alias_image() {
    IMG_1=$1; TAG_1=$2; IMG_2=$3; TAG_2=$4; shift 4; VER=`date +%Y.%m%d`;
    [[ "$TRAVIS_PULL_REQUEST_BRANCH" == "" ]] && BASE_NAMESPACE="${NAMESPACE}" || BASE_NAMESPACE="${NAMESPACE}0${TRAVIS_PULL_REQUEST_BRANCH}" ;
    docker tag "${BASE_NAMESPACE}/${IMG_1}:${TAG_1}" "${BASE_NAMESPACE}/${IMG_2}:${TAG_2}" ;
    docker tag "${BASE_NAMESPACE}/${IMG_2}:${TAG_2}" "${BASE_NAMESPACE}/${IMG_2}:${VER}" ;
}

push_image() {
    docker image prune --force && docker images ;
    IMGS=$(docker images | grep "second" | awk '{print $1 ":" $2}') ;
    echo "$DOCKER_REGISTRY_PASSWORD" | docker login "${REGISTRY_URL}" -u "$DOCKER_REGISTRY_USER" --password-stdin ;
    for IMG in $(echo $IMGS | tr " " "\n") ;
    do
      docker push "${IMG}";
      status=$?;
      echo "[${status}] Image pushed > ${IMG}";
    done
}
