#!/bin/bash

rm k8ssandra-datacenter-single.yaml
cat <<EOF | tee k8ssandra-datacenter-single.yaml
cassandra:
  image: {}
	  image:
		  registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
  configBuilder:
	  image:
		  registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
  applyCustomConfig:
	  image:
		  registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
  jmxCredentialsConfig:
	  image:
		  registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
  loggingSidecar:
	  image:
		  registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
  waitForCassandra:
	  image:
		  registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
  image:
	  registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
 cleaner:
   image:
	   registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
 client:
   image:
	   registry: harbor-repo.vmware.com/dockerhub-proxy-cache/
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

kubectl port-forward -n k8ssandra svc/k8ssandra-dc1-stargate-service 8080 8081 8082 9042 &
	