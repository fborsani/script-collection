GITLAB_HOME="/home/ubuntu/GitLab"
TAG_VERSION="gitlab-ee:15.11.8-ee.0"

HOST_PUBLIC="public server name"
HOST_PRIVATE="hostname"
PORT_HTTP=8080
PORT_HTTPS=8443
PORT_SSH=22

mkdir -p "$GITLAB_HOME/config"
mkdir -p "$GITLAB_HOME/logs"
mkdir -p "$GITLAB_HOME/data"

sudo docker run --detach \
  --hostname $HOST_PUBLIC \
  --env GITLAB_OMNIBUS_CONFIG="gitlab_rails['gitlab_shell_ssh_port'] = ${PORT_SSH}; gitlab_rails['gitlab_ssh_host'] = '${HOST_PRIVATE}'" \
  --publish $PORT_HTTPS:443 --publish $PORT_HTTP:80 --publish $PORT_SSH:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/"$TAG_VERSION"