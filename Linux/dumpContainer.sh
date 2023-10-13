container=$1

if [ -n "$container" ]; then
	echo "Usage: $0 <container name>"
	exit
if

container_backup=${container}_backup_$(date +%s)
docker commit ${container} ${container_backup}
docker save -o "./${container}.tar" ${container_backup}
docker rm ${container_backup}

echo "Container dumped in ./${container_backup}"