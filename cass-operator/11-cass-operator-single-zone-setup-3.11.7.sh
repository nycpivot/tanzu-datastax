#!/bin/bash

rm cass-datacenter-single-3.11.7.yaml
cat <<EOF | tee cass-datacenter-single-3.11.7.yaml
# This example shows off most customization options Cass Operator offers. It's
# built to run on a 6 node regional GKE 1.15.x cluster in the us-central1 region
# with a node pool covering the a, b, and c zones. Data will be stored in a
# rack-safe way across the zones, and it's expected the user will be using RF=3
# keyspaces. The request/limts/configuration is based on k8s worker nodes with
# at least 8 CPUs and 30 GB RAM, but these numbers can be adjusted.
apiVersion: cassandra.datastax.com/v1beta1
kind: CassandraDatacenter
metadata:
  # The datacenter name.
  name: cdc-single
  namespace: cass-operator
spec:
  # The cluster name.
  clusterName: cass-cluster-single
  # The number of server nodes.
  size: 3
  # Limit each pod to a fixed 6 CPU cores and 24 GB of RAM.
  resources:
    requests:
      memory: 24Gi
      cpu: 6000m
    limits:
      memory: 24Gi
      cpu: 6000m
  # The storage configuration. This sets up a 100GB volume at /var/lib/cassandra
  # on each server pod. The user is left to create the server-storage storage
  # class by following these directions...
  # https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/ssd-pd
  # Make sure to use 'volumeBindingMode: WaitForFirstConsumer' in the resource.
  # If you run out of SSD quota in GKE, the PVCs will be left in Pending state
  # until you increase quota or consume less.
  storageConfig:
    cassandraDataVolumeClaimSpec:
      storageClassName: server-storage
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
  # Multiple server pods running on one k8s worker is disabled by default.
  # Enabling this is an advanced use case.
  allowMultipleNodesPerWorker: false
  # Setting stopped to true scales the StatefulSets that Cass Operator creates
  # to zero replicas, in a graceful way. The PersistentVolumeClaims and
  # PersistentVolumes remain intact.
  stopped: false
  # Setting rollingRestartRequested to true will have Cass Operator do a rolling
  # restart on this CassDC at the next opportunity. The operator will set this
  # back to false once the restart is in progress.
  rollingRestartRequested: false
  # Using canaryUpgrade will limit config changes that directly impact the
  # underlying StatefulSets resources (which is most of them) to only updating
  # the first StatefulSet / rack. Users can use this to test configuration
  # changes before rolling them out to the whole cluster.
  canaryUpgrade: false
  # Which server distribution to use. Required.
  serverType: "cassandra"
  # Which server version to use. Required.
  serverVersion: "3.11.7"
  # Use the serverImage configuration to override Cass Operator's logic to map
  # the serverType plus serverVersion into a public container image on Docker
  # Hub.
  serverImage: ""
  # This allows the user to override the default location of the
  # cass-config-builder image. It is the init container that turns the config
  # information below into config files on the filesystem in each server pod.
  configBuilderImage: ""
  # Use superuserSecretName to setup superuser pre-defined credentials for the
  # database in a Kubernetes secret. Cass Operator will read the secret and pass
  # the values to the Management API when managing the cluster. If this is
  # empty, Cass Operator will generate a secret instead.
  superuserSecretName: "cassandra-admin-secret"
  # Users must provide managementApiAuth.
  # If insecure is used, the operator will not secure the Management API on each
  # pod with mutual TLS.
  # If manual is used, Cass Operator will load the clientSecretName and
  # serverSecretName as secrets and and secure the Management API on each pod
  # with mutual TLS encryption.
  # More options will be available here in the future.
  managementApiAuth:
    insecure: {}
    # manual:
      # clientSecretName: mgmt-api-client-credentials
      # serverSecretName: mgmt-api-server-credentials
      # skipSecretValidation: false
  # The Kubernetes service account to use for the server pods. Useful for
  # working with a private image registry and its image pull secret.
  serviceAccount: "default"
  # A list of pod names that need to be replaced. See the following:
  # http://cassandra.apache.org/doc/latest/operating/topo_changes.html#replacing-a-dead-node
  replaceNodes: []
  # Everything under the config key is passed to the cass-config-builder init
  # container that runs on pod creation, and then marshalled into config files.
  config:

    # See http://cassandra.apache.org/doc/latest/configuration/cassandra_config_file.html
    cassandra-yaml:
      num_tokens: 8
      file_cache_size_in_mb: 1000
      authenticator: org.apache.cassandra.auth.PasswordAuthenticator
      authorizer: org.apache.cassandra.auth.CassandraAuthorizer
      role_manager: org.apache.cassandra.auth.CassandraRoleManager
    jvm-options:
      # Set the database to use 14 GB of Java heap
      initial_heap_size: "14G"
      max_heap_size: "14G"
      additional-jvm-opts:
        # As the database comes up for the first time, set system keyspaces to RF=3
        - "-Dcassandra.system_distributed_replication_dc_names=cdc-single"
        - "-Dcassandra.system_distributed_replication_per_dc=3"
EOF
		
kubectl apply -f cass-datacenter-single-3.11.7.yaml

kubectl get pods -n cass-operator -w

#kubectl -n cass-operator get pods --selector cassandra.datastax.com/cluster=cass-cluster-single
#kubectl -n cass-operator get cassdc/cass-datacenter-single -o "jsonpath={.status.cassandraOperatorProgress}"
