#!bin/bash

#https://docs.datastax.com/en/cass-operator/doc/cass-operator/cassOperatorConnectWithinK8sCluster.html

kubectl exec -it $pod_name -n cass-operator -c cassandra -- sh -c "cqlsh -u 'cassandra-admin' -p 'cassandra-admin-password'"

CREATE KEYSPACE k8ssandra_test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE k8ssandra_test;
CREATE TABLE users (email text primary key, name text, state text);

INSERT INTO users (email, name, state) values ('alice@example.com', 'Alice Smith', 'TX');
INSERT INTO users (email, name, state) values ('bob@example.com', 'Bob Jones', 'VA');
INSERT INTO users (email, name, state) values ('carol@example.com', 'Carol Jackson', 'CA');
INSERT INTO users (email, name, state) values ('david@example.com', 'David Yang', 'NV');

SELECT * FROM k8ssandra_test.users;
