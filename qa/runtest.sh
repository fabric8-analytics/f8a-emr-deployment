#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

pushd "${SCRIPT_DIR}/.." > /dev/null

TEST_IMAGE_NAME='emr-deployment-tests'

check_python_version() {
    python3 tools/check_python_version.py 3 6
}

gc() {
    docker rmi -f $(make get-image-name)
    docker rmi -f "${TEST_IMAGE_NAME}"
}

# be sure we use Python 3.6 or never
check_python_version
mkdir shared

if [[ "$CI" -eq "0" ]];
then
    make docker-build-test
    docker run -v "$PWD/shared:/shared" ${TEST_IMAGE_NAME}
    docker stop ${TEST_IMAGE_NAME}
    trap gc EXIT SIGINT
else
    # CI instance will be torn down anyway, don't need to waste time on gc
    docker run -v "$PWD/shared:/shared" ${TEST_IMAGE_NAME}
fi
popd > /dev/null
