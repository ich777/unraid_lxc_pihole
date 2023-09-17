#!/bin/bash

if [ ! -f /boot/config/plugins/lxc.plg ]; then
  echo "ERROR: LXC plugin not found!"
  exit 1
fi

# get variables
LXC_PATH=$(cat /boot/config/plugins/lxc/lxc.conf | grep "lxc.lxcpath" | cut -d '=' -f2)
LXC_PACKAGE_NAME=pihole
LXC_PACKAGE_DIR=${LXC_PATH}/cache/build_cache
LXC_DISTRIBUTION=debian
LXC_RELEASE=bookworm
LXC_ARCH=amd64
LXC_BUILD_ROOT=$(cd "$(dirname "$0")" && pwd)

# check if build machine uses /mnt/user
if echo ${LXC_PATH} | grep -q "/mnt/user" ; then
  echo "ERROR: LXC path /mnt/user is not allowed!"
fi

# generate temporary LXC container name
LXC_CONT_NAME=$(openssl rand -base64 24 | tr -dc 'a-z0-9' | cut -c -12)

# check if build cache directory exist
if [ ! -d ${LXC_PACKAGE_DIR} ]; then
  mkdir -p ${LXC_PACKAGE_DIR}
fi

# create log file with build date and time
echo "Build time: $(date +"%Y-%m-%d %H:%M")" > ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_startdate.log

# create LXC container
echo "Creating temporary container"
lxc-create --name ${LXC_CONT_NAME} \
  --template download -- \
  --dist ${LXC_DISTRIBUTION} \
  --release ${LXC_RELEASE} \
  --arch ${LXC_ARCH} > ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_create.log

# build file list for build scripts
echo "Generating build script list"
LXC_BUILD_FILES=$(ls -1 ${LXC_BUILD_ROOT}/build/ | grep "^[0-9][0-9]-" | sort)

# start LXC container and attach
echo "Starting temporary container"
lxc-start -n ${LXC_CONT_NAME}
echo "Waiting 10 seconds for temporary container to become online"
sleep 10

# create /tmp directory in container if it not exists and copy build scripts
echo "Copying build directory to container"
cp -R ${LXC_BUILD_ROOT}/build ${LXC_PATH}/${LXC_CONT_NAME}/rootfs/tmp/build

# loop through build scripts
echo "Executing build scripts in container"
IFS=$'\n'
for script in ${LXC_BUILD_FILES}; do
  echo "Executing build script $script in container"
  lxc-attach -n ${LXC_CONT_NAME} -- bash -c "chmod +x /tmp/build/$script && /tmp/build/$script 2>&1 | tee /tmp/${script%.*}.log"
done

# stop LXC container
echo "Stopping temporary container"
lxc-stop -n ${LXC_CONT_NAME} -t 15 2>/dev/null

# copy over build log files
echo "Copying over build logs from container"
for script in ${LXC_BUILD_FILES}; do
  cp ${LXC_PATH}/${LXC_CONT_NAME}/rootfs/tmp/${script%.*}.log ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_${script%.*}.log
done

# navigate to LXC container path, remove .bash_histroy, remove parts from
# config which is generated on installation from the container archive and
# remove installation script
echo "Performing final cleanup from container"
cd ${LXC_PATH}/${LXC_CONT_NAME}
find . -name ".bash_history" -exec rm {} \;
rm -rf ${LXC_PATH}/${LXC_CONT_NAME}/rootfs/tmp/*
sed -i '/# Container specific configuration/,$d' config

# combine and copy build log to package directory
echo "Generating build.log"
cat ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_startdate.log \
  ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_create.log > ${LXC_PACKAGE_DIR}/build.log
rm ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_startdate.log \
  ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_create.log

for script in ${LXC_BUILD_FILES}; do
  cat ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_${script%.*}.log >> ${LXC_PACKAGE_DIR}/build.log
  rm ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}_${script%.*}.log
done

# create container archive and md5 sum
echo "Packing up container"
tar -cf - . | xz -9 --threads=$(nproc --all) > ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz
echo "Creating md5 checksum"
md5sum ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz | awk '{print $1}' > ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz.md5
echo "--------------------END--------------------" >> ${LXC_PACKAGE_DIR}/build.log

# upload to GitHub
#TBD

# remove packages (comment if you don't want to remove them)
#rm -rf ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz ${LXC_PACKAGE_DIR}/${LXC_PACKAGE_NAME}.tar.xz.md5 ${LXC_PACKAGE_DIR}/build.log

# remove container
echo "Stopping and destroying temporary container"
lxc-stop -k -n ${LXC_CONT_NAME} 2>/dev/null
lxc-destroy -n ${LXC_CONT_NAME}
