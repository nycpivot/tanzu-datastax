# Database Operations

## CQLSH CLI

Ensure you have setup port-forwarding with the following command.

<pre>
	kubectl port-forward -n k8ssandra svc/k8ssandra-dc1-stargate-service 8080 8081 8082 9042 &
</pre>

From another terminal, install the CQLSH CLI with python package manager.

<pre>
	pip install -U cqlsh
</pre>

Login to the Cassandra database with CQLSH.

<pre>
	cqlsh -u cassandra-admin -p cassandra-admin-password
</pre>

At this point, you can execute DDL/DML statements against the database.

<pre>
	CREATE KEYSPACE k8ssandra_test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

	USE k8ssandra_test;
	CREATE TABLE users (email text primary key, name text, state text);

	INSERT INTO users (email, name, state) values ('alice@example.com', 'Alice Smith', 'TX');
	INSERT INTO users (email, name, state) values ('bob@example.com', 'Bob Jones', 'VA');
	INSERT INTO users (email, name, state) values ('carol@example.com', 'Carol Jackson', 'CA');
	INSERT INTO users (email, name, state) values ('david@example.com', 'David Yang', 'NV');

	SELECT * FROM k8ssandra_test.users;
</pre>

## Stargate API

Retreive a token from the authentication service and run simple curl commands.

<pre>
	authToken=$(curl -L -X POST 'http://localhost:8081/v1/auth' -H 'Content-Type: application/json' --data-raw '{"username": "cassandra-admin", "password": "cassandra-admin-password"}')

	cassToken=$(jq '.authToken' <<< "$authToken" | tr -d '"')

	curl -X 'GET' \
		'http://localhost:8082/v1/keyspaces/k8ssandra_test/tables/users/rows' \
		-H 'accept: application/json' \
		-H "X-Cassandra-Token: ${cassToken}"
	
	echo $cassToken
</pre>

Test the API endpoints with the Swagger user interface.

<pre>
	http://127.0.0.1:8082/swagger-ui
</pre>

For more information, refer to the following link.
https://k8ssandra.io/get-started/developers/#access-cassandra-using-the-stargate-apis
