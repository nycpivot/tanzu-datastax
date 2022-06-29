#!/bin/bash

kubectl port-forward -n k8ssandra svc/k8ssandra-dc1-stargate-service 8080 8081 8082 9042 &



read -p "Select pod: " pod

kubectl exec $pod cassandra -it -n cass-operator -- cqlsh -u cassandra-admin -p cassandra-admin-password

