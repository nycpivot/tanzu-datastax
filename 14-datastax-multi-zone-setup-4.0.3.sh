#!/bin/bash

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml

kubectl apply -f https://raw.githubusercontent.com/k8ssandra/cass-operator/master/operator/k8s-flavors/eks/storage.yaml

kubectl apply -f https://raw.githubusercontent.com/k8ssandra/cass-operator/v1.7.1/docs/user/cass-operator-manifests.yaml

kubectl create secret generic cassandra-admin-secret -n cass-operator \
	--from-literal=username=cassandra-admin \
	--from-literal=password=cassandra-admin-password
	
kubectl get pods -n cass-operator -w

rm cass-datacenter-multi-4.0.3.yaml
cat <<EOF | tee cass-datacenter-multi-4.0.3.yaml
apiVersion: cassandra.datastax.com/v1beta1
kind: CassandraDatacenter
metadata:
  name: cass-datacenter-multi
	namespace: cass-operator
spec:
  clusterName: cass-cluster-multi
  serverType: cassandra
  serverVersion: "4.0.3"
  managementApiAuth:
    insecure: {}
  size: 3
  storageConfig:
      cassandraDataVolumeClaimSpec:
        storageClassName: server-storage
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
  dockerImageRunsAsCassandra: true
  resources:
    requests:
      memory: 2Gi
      cpu: 1000m
  racks:
    - name: rack1
      nodeAffinityLabels:
        failure-domain.beta.kubernetes.io/zone: us-east-1a
    - name: rack2
      nodeAffinityLabels:
        failure-domain.beta.kubernetes.io/zone: us-east-1b
    - name: rack3
      nodeAffinityLabels:
        failure-domain.beta.kubernetes.io/zone: us-east-1c
  config:
    jvm-server-options:
      initial_heap_size: "1G"
      max_heap_size: "1G"
    cassandra-yaml:
      num_tokens: 16
      file_cache_size_in_mb: 1000
      authenticator: PasswordAuthenticator
      authorizer: CassandraAuthorizer
      role_manager: CassandraRoleManager
    # additional-jvm-opts:
    #   - "-Dcassandra.system_distributed_replication_dc_names=cass-datacenter-multi"
    #   - "-Dcassandra.system_distributed_replication_per_dc=3"
EOF
		
kubectl apply -f cass-datacenter-multi-4.0.3.yaml

kubectl get pods -n cass-operator -w

#kubectl -n cass-operator get pods --selector cassandra.datastax.com/cluster=cass-cluster-multi
#kubectl -n cass-operator get cassdc/cass-datacenter-multi -o "jsonpath={.status.cassandraOperatorProgress}"

