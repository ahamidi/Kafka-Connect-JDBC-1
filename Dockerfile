FROM ubuntu:18.04

RUN apt-get update && \
apt-get install -y wget gnupg2 software-properties-common default-jre && \
wget -qO - https://packages.confluent.io/deb/5.3/archive.key | apt-key add - && \
add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.3 stable main" && \
apt-get install -y confluent-community-2.12 && \
apt-get install -y emacs

WORKDIR /usr/src/app
COPY . .