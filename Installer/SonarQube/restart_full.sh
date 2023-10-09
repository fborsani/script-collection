#!/bin/bash
echo [*] Stopping containers...
docker container stop sonarqube
docker container stop sonarqube_db
echo [+] Containers stopped
docker rm sonarqube
docker rm sonarqube_db
echo [+] Containers removed
echo [*] Launching containers...
docker run -d --name sonarqube_db -v sonarqube_db_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres postgres
DB_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' sonarqube_db)
echo [+] Postgres is up
docker run -d --name sonarqube -p 37081:9000 --security-opt seccomp=/home/ubuntu/SonarQube/Resources/seccomp-profile.json -e SONAR_JDBC_URL=jdbc:postgresql://${DB_IP}/sonar?default_schema=public -e SONAR_JDBC_USERNAME=postgres -e SONAR_JDBC_PASSWORD=postgres -v sonarqube_data:/opt/sonarqube/data -v sonarqube_logs:/opt/sonarqube/logs -v sonarqube_extensions:/opt/sonarqube/extensions -v sonarqube_conf:/opt/sonarqube/conf  sonarqube:9.3.0-community
echo [+] SonarQube is up
echo [*] Installing plugins...
mkdir /tmp/sonarPlugins
wget https://github.com/gjd6640/sonar-text-plugin/releases/download/v2.2.0/sonar-text-plugin-1.1.6.jar -P /tmp/sonarPlugins
wget https://github.com/Inform-Software/sonar-groovy/releases/download/1.8/sonar-groovy-plugin-1.8.jar -P /tmp/sonarPlugins
wget https://github.com/InfoSec812/sonar-auth-google/releases/download/untagged-b38ce896a2ef581af1ee/sonar-auth-googleoauth-plugin-1.6.4-SNAPSHOT.jar -P /tmp/sonarPlugins
docker cp /tmp/sonarPlugins/. sonarqube_9_ext:/opt/sonarqube/extensions/plugins
rm -rf /tmp/sonarPlugins
echo [+] Plugins installed
echo [+] Restart done