#!/bin/bash
# Set Variables
SERVICE_NAME="unbound"
UB_FOLDER="/etc/unbound"
FILE_NAME="root.hints"
ROOT_HINTS_URL="https://www.internic.net/domain/named.root"

#Get current version
CUR_V="$(cat ${UB_FOLDER}/${FILE_NAME} 2>/dev/null | grep "related version of root zone" | awk '{print $NF}')"

#Download new root.hints
cd ${UB_FOLDER}
wget -q -O ${UB_FOLDER}/new.${FILE_NAME##*.} "${ROOT_HINTS_URL}"

#Compare versions
if [ ! -s "${UB_FOLDER}/new.${FILE_NAME##*.}" ]; then
  echo "New roothints file is empty!"
  rm ${UB_FOLDER}/new.${FILE_NAME##*.}
elif [ "${UB_FOLDER}/new.${FILE_NAME##*.}" -nt "${UB_FOLDER}/${FILE_NAME}" ]; then
  echo "Update from ${FILE_NAME}, restarting service: ${SERVICE_NAME}"
  cp ${UB_FOLDER}/new.${FILE_NAME##*.} ${UB_FOLDER}/${FILE_NAME}
  rm ${UB_FOLDER}/new.${FILE_NAME##*.}
  systemctl restart ${SERVICE_NAME}
else
  echo "Nothing to do, ${FILE_NAME} up-to-date"
  rm ${UB_FOLDER}/new.${FILE_NAME##*.}
fi
