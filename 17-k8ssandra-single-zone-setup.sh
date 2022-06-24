#!/bin/bash

rm k8ssandra-datacenter-single.yaml
cat <<EOF | tee k8ssandra-datacenter.yaml
cassandra:
  auth:
    superuser:
      secret: cassandra-admin-secret
  cassandraLibDirVolume:
    storageClass: server-storage
  clusterName: k8ssandra-cluster-single
  data centers:
  - name: k8s-single
    size: 3
EOF
		
helm repo add k8ssandra https://helm.k8ssandra.io/stable

helm install k8ssandra k8ssandra/k8ssandra -f k8ssandra-datacenter-single.yaml -n k8ssandra
	
kubectl get pods -n k8ssandra -w
