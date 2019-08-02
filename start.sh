#!/usr/bin/env bash

printenv KAFKA_CLIENT_CERT_KEY >> .keystore.pem
printenv KAFKA_CLIENT_CERT >> .keystore.pem
printenv KAFKA_TRUSTED_CERT >> .truststore.pem

keytool -importcert -file .truststore.pem -keystore .truststore.jks -deststorepass abc123abc -noprompt
openssl pkcs12 -export -in .keystore.pem -out .keystore.pkcs12 -password pass:abc123abc
keytool -importkeystore -srcstoretype PKCS12 -destkeystore .keystore.jks -deststorepass abc123abc -srckeystore .keystore.pkcs12 -srcstorepass abc123abc

cat > worker.properties <<PROPERTIES
bootstrap.servers=${KAFKA_URL//kafka+ssl:\/\//""}
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafka.connect.json.JsonConverter
rest.port=$PORT
plugin.path=/usr/share/java
group.id=jdbckafkaconnect

config.storage.topic=connect-configs
config.storage.replication.factor=3
config.storage.partitions=1

offset.storage.topic=connect-offsets
offset.storage.replication.factor=3
offset.storage.partitions=50

status.storage.topic=connect-status
status.storage.replication.factor=3
status.storage.partitions=10

producer.security.protocol=SSL
producer.ssl.truststore.location=$HOME/.truststore.jks
producer.ssl.truststore.password=abc123abc
producer.ssl.keystore.location=$HOME/.keystore.jks
producer.ssl.keystore.password=abc123abc
producer.ssl.key.password=abc123abc
producer.ssl.endpoint.identification.algorithm=

consumer.security.protocol=SSL
consumer.ssl.truststore.location=$HOME/.truststore.jks
consumer.ssl.truststore.password=abc123abc
consumer.ssl.keystore.location=$HOME/.keystore.jks
consumer.ssl.keystore.password=abc123abc
consumer.ssl.key.password=abc123abc
consumer.ssl.endpoint.identification.algorithm=

security.protocol=SSL
ssl.truststore.location=$HOME/.truststore.jks
ssl.truststore.password=abc123abc
ssl.keystore.location=$HOME/.keystore.jks
ssl.keystore.password=abc123abc
ssl.key.password=abc123abc
ssl.endpoint.identification.algorithm=
PROPERTIES

connect-distributed worker.properties
