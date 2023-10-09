#!/bin/bash
echo [*] Stopping containers...
docker container stop sonarqube_9
docker container stop sonarqube_db
echo [+] Containers stopped
docker rm sonarqube_9
docker rm sonarqube_db
echo [+] Containers removed
echo [*] Launching containers...
docker run -d --name sonarqube_db -v sonarqube_db_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres postgres
DB_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' sonarqube_db)
echo [+] Postgres is up
docker run -d --name sonarqube -p 37081:9000 --security-opt seccomp=/home/ubuntu/SonarQube/Resources/seccomp-profile.json -e SONAR_JDBC_URL=jdbc:postgresql://${DB_IP}/sonar?default_schema=public -e SONAR_JDBC_USERNAME=postgres -e SONAR_JDBC_PASSWORD=postgres -v sonarqube_data:/opt/sonarqube/data -v sonarqube_logs:/opt/sonarqube/logs -v sonarqube_extensions:/opt/sonarqube/extensions -v sonarqube_conf:/opt/sonarqube/conf  sonarqube:9.3.0-community
echo [+] SonarQube is up
echo [+] Restart done