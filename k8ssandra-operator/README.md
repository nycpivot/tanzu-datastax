#!/bin/bash
#https://k8ssandra.io/get-started/developers/#access-cassandra-using-the-stargate-apis

#CQLSH
pip install -U cqlsh

cqlsh -u cassandra-admin -p cassandra-admin-password

CREATE KEYSPACE k8ssandra_test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE k8ssandra_test;
CREATE TABLE users (email text primary key, name text, state text);

INSERT INTO users (email, name, state) values ('alice@example.com', 'Alice Smith', 'TX');
INSERT INTO users (email, name, state) values ('bob@example.com', 'Bob Jones', 'VA');
INSERT INTO users (email, name, state) values ('carol@example.com', 'Carol Jackson', 'CA');
INSERT INTO users (email, name, state) values ('david@example.com', 'David Yang', 'NV');

SELECT * FROM k8ssandra_test.users;


#TO OBSERVE REPLICATION IN ACTION, LOG INTO ANOTHER POD AND EXECUTE THE SELECT COMMAND
kubectl exec -it $pod_name -n cass-operator -c cassandra -- sh -c "cqlsh -u 'cassandra-admin' -p 'cassandra-admin-password'"

SELECT * FROM k8ssandra_test.users;


#STARGATE API
authToken=$(curl -L -X POST 'http://localhost:8081/v1/auth' -H 'Content-Type: application/json' --data-raw '{"username": "cassandra-admin", "password": "cassandra-admin-password"}')

cassToken=$(jq '.authToken' <<< "$authToken" | tr -d '"')

echo $cassToken

curl -X 'GET' \
  'http://localhost:8082/v1/keyspaces/k8ssandra_test/tables/users/rows' \
  -H 'accept: application/json' \
  -H "X-Cassandra-Token: ${cassToken}"

http://127.0.0.1:8082/swagger-ui