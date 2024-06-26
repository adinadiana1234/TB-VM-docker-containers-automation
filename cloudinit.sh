#!/bin/bash

# remove existing docker installations
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# install docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# start and enable docker service
sudo systemctl start docker
sudo systemctl enable docker 

getent group docker

# add your linux user to the docker group 
sudo usermod -aG docker opc
getent group docker

# Create docker-compose.yml
cat <<EOF > /home/opc/docker-compose.yml
version: '3.0'
services:
  zookeeper:
    restart: always
    image: "zookeeper:3.5"
    ports:
      - "2181:2181"
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=zookeeper:2888:3888;zookeeper:2181
  kafka:
    restart: always
    image: wurstmeister/kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_LISTENERS: INSIDE://:9093,OUTSIDE://:9092
      KAFKA_ADVERTISED_LISTENERS: INSIDE://:9093,OUTSIDE://kafka:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: INSIDE
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
  mytb:
    restart: always
    image: "thingsboard/tb-postgres"
    depends_on:
      - kafka
    ports:
      - "8080:9090"
      - "1883:1883"
      - "7070:7070"
      - "5683-5688:5683-5688/udp"
    environment:
      TB_QUEUE_TYPE: kafka
      TB_KAFKA_SERVERS: kafka:9092
    volumes:
      - ~/.mytb-data:/data
      - ~/.mytb-logs:/var/log/thingsboard
EOF
chown opc:opc /home/opc/docker-compose.yml


# Create necessary directories and set permissions
mkdir -p /home/opc/.mytb-data && sudo chown -R 799:799 /home/opc/.mytb-data
mkdir -p /home/opc/.mytb-logs && sudo chown -R 799:799 /home/opc/.mytb-logs

# Run Docker Compose as user 'opc'
sudo -H -u opc bash -c "docker compose -f /home/opc/docker-compose.yml up -d"