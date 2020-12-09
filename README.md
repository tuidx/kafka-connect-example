
# kafka-connect-jdbc-source-connector
The aim of this project is to describe how to create a streamming data flow with Kafka Connect.
The compose file contains all the necessary services that need to be started:
- Zookeper
- Kafka broker
- Kakfa Schema Registry
- Kafka Connect
- Confluent Control Center
- Postgresql

## 1. Zookeper
- To start this service we use the docker confluent image: confluentinc/cp-zookeeper and use export the port 2181
## 2. Kafka broker

 - To start this service we use the docker confluent image:
   confluentinc/cp-kafka.   
 - The installation just contains one broker so
   the replication factor will be one.  
 -  We must set the environment
   variables to indicate the next services dependencies:
	 - KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
	 - KAFKA_CONFLUENT_SCHEMA_REGISTRY_URL: http://schema-registry:8081
## 3. Kafka Schema Registry
 - To start this service we use the docker confluent image:
   confluentinc/cp-schema-registry.    
 - This services will be used to set up a JsonSchemaConverter for the topic messages values. In this way, when we register a connector, it will automatically register the  table scheme in json format, thus avoiding replicating the scheme in  each of the messages in the topic.

## 4. Kafka Connect

 - This is the main service, the one that will get the data from our database and will publish into a Kafka topic. We must set the dependencies with zookeeper,  the kafka broker and the kafka schema registry:
	- CONNECT_BOOTSTRAP_SERVERS: kafka:29092
	- CONNECT_ZOOKEEPER_CONNECT: zookeeper:2181
	- CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL: http://schema-registry:8081

- Other important variables to be configured are the converters that will be used for the key and the value of each topic message:

	- CONNECT_KEY_CONVERTER: "org.apache.kafka.connect.storage.StringConverter" 
	- CONNECT_VALUE_CONVERTER: "io.confluent.connect.json.JsonSchemaConverter"

- We must also establish the plugins path where the connectors will be allocated:
	- CONNECT_PLUGIN_PATH: /usr/share/java,/etc/kafka-connect/jars

	We will define a volume to load our jdbc driver. We can download the driver from https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc, this will take you to a website where you can click on the download and you will get a zip file,  just have to unzip the file in the path of your local plugin folder.
	
## 5. Creating JDBC source connector for Postgres database

Once we have start-up the all infrastructure by means of exectuing the command: **`docker-compose up`** we can create the JDBC source connector by sending an HTTP request to the local kafka connect service. See the example of a curl request:

> curl -s -X POST \   -H "Content-Type: application/json" \   --data
> '{"name": "jdbc_source_connector_postgresql_01",    "config": { 
> "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
> "connection.url": "jdbc:postgresql://postgresql:5432/influencers",
> "connection.user": "user", 
> "connection.password": 1234,
> "topic.prefix": "influencers-01-",
>  "validate.non.null": false,
> "poll.interval.ms" : 10000, 
> "mode":"incrementing",
> "transforms":"createKey,extractInt",
> "transforms.createKey.type":"org.apache.kafka.connect.transforms.ValueToKey",
> "transforms.createKey.fields":"id",
> "transforms.extractInt.type":"org.apache.kafka.connect.transforms.ExtractField$Key",
> "transforms.extractInt.field":"id",
>  "table.whitelist":"user",
> "dialect.name":"PostgreSqlDatabaseDialect"}}'
> http://localhost:8083/connectors

With the command above kafka connect will retrieve all the new messages in the **user** table and will publish the new entries in the topic named influencers-01-user.  Note that in this example we are only tracking the new entries in the database, if we wanted to include the updates we would have to specify an new attribute in the user table with the timestamp, and change the mode of the connector to timestamp+incremmeting

	
