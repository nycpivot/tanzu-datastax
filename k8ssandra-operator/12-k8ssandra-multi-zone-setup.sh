#!/bin/bash

rm k8ssandra-datacenter-multi.yaml
cat <<EOF | tee k8ssandra-datacenter-multi.yaml
cassandra:
  auth:
    superuser:
      secret: cassandra-admin-secret
  cassandraLibDirVolume:
    storageClass: server-storage
  clusterName: k8ssandra-cluster-multi
  data centers:
  - name: k8s-multi
    size: 3
    racks:
    - name: rack1
      affinityLabels:
        failure-domain.beta.kubernetes.io/zone: us-east-1a
    - name: rack2
      affinityLabels:
        failure-domain.beta.kubernetes.io/zone: us-east-1b
    - name: rack3
      affinityLabels:
        failure-domain.beta.kubernetes.io/zone: us-east-1c
EOF
		
helm repo add k8ssandra https://helm.k8ssandra.io/stable

helm install k8ssandra k8ssandra/k8ssandra -f k8ssandra-datacenter-multi.yaml -n k8ssandra
	
kubectl get pods -n k8ssandra -w
