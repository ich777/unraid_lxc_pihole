# Install Docker if not installed
if [ ! -f /usr/bin/docker ]; then
  echo "Docker not found, installing!"
  cd /tmp
  curl -fsSL https://get.docker.com -o get-docker.sh
  chmod +x /tmp/get-docker.sh
  /tmp/get-docker.sh
  rm /tmp/get-docker.sh
fi

# Pull latest lancache, stop already running instance and remove currently installed container
docker pull lancachenet/monolithic
docker container stop LANCache 2>/dev/null
docker container rm LANCache 2>/dev/null

# Recreate LANCache container
docker run -d --name='LANCache' \
  --net='host' \
  -e CACHE_DISK_SIZE="1000g" \
  -e CACHE_INDEX_SIZE="250m" \
  -e CACHE_MAX_AGE="3650d" \
  -e UPSTREAM_DNS="127.0.0.1:8053" \
  -e FORCE_PERMS_CHECK="false" \
  -e TZ="Europe/Berlin" \
  -v '/mnt/lancache/cache':'/data/cache':'rw' \
  -v '/mnt/lancache/logs':'/data/logs':'rw' \
  --no-healthcheck \
  --restart=unless-stopped \
  --log-driver=none \
  'lancachenet/monolithic'

# Remove dangling Docker images
docker rmi $(docker images -f dangling=true -q) 2>/dev/null

# Clear LANCache access log
echo -n "" > /mnt/lancache/logs/access.log
