#!bin/bash

#https://github.com/k8ssandra/cass-operator

kubectl config use-context tanzu-datastax

wget https://raw.githubusercontent.com/k8ssandra/cass-operator/v1.7.1/docs/user/cass-operator-manifests.yaml
kubectl apply -f cass-operator-manifests.yaml

wget https://raw.githubusercontent.com/k8ssandra/cass-operator/master/operator/k8s-flavors/eks/storage.yaml
kubectl apply -f storage.yaml

#DATA CENTER
wget https://raw.githubusercontent.com/k8ssandra/cass-operator/master/operator/example-cassdc-yaml/dse-6.8.x/example-cassdc-minimal.yaml
kubectl apply -f example-cassdc-minimal.yaml -n cass-operator


#SSH BEGIN
#https://docs.datastax.com/en/cass-operator/doc/cass-operator/cassOperatorConnectWithinK8sCluster.html
kubectl get secret -o yaml cluster2-superuser -n cass-operator

echo 'xxx' | base64 -d

kubectl exec -ti cluster2-dc1-default-sts-0 -n cass-operator -c cassandra -- sh -c "cqlsh -u 'cluster2-superuser' -p 'AlJIZloOfbwb38SNbxjVNhV_h9gBZmxM1QEIGHaNkWXUmiy6rURdNw'"
#kubectl exec -n cass-operator -i -t -c cassandra cluster2-dc1-default-sts-0 -- /opt/cassandra/bin/cqlsh -u cluster2-superuser -p AlJIZloOfbwb38SNbxjVNhV_h9gBZmxM1QEIGHaNkWXUmiy6rURdNw
#SSH END





































helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm repo update

helm install cass-operator k8ssandra/cass-operator -n cass-operator --create-namespace








kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml

#CASS-OPERATOR
kubectl apply --force-conflicts --server-side -k github.com/k8ssandra/cass-operator/config/deployments/cluster?ref=v1.11.0




#PROMETHEUS (RETURNS AN ERROR)
kubectl apply -k github.com/k8ssandra/cass-operator/config/prometheus?ref=v1.11.0











apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: server-storage
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: none
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete

kubectl apply -f storage.yaml

apiVersion: cassandra.datastax.com/v1beta1
kind: CassandraDatacenter
metadata:
  name: dc1
spec:
  clusterName: development
  serverType: cassandra
  serverVersion: "4.0.1"
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
  dockerImageRunsAsCassandra: false
  resources:
    requests:
      memory: 2Gi
      cpu: 1000m
  podTemplateSpec:
    securityContext: {}
    containers:
      - name: cassandra
        securityContext: {}
  racks:
    - name: rack1
  config:
    jvm-server-options:
      initial_heap_size: "1G"
      max_heap_size: "1G"
    cassandra-yaml:
      num_tokens: 16
      authenticator: PasswordAuthenticator
      authorizer: CassandraAuthorizer
      role_manager: CassandraRoleManager

kubectl apply -f cass-datacenter.yaml -n cass-operator