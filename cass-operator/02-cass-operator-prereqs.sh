#!/bin/bash

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml

kubectl apply -f https://raw.githubusercontent.com/k8ssandra/cass-operator/v1.7.1/docs/user/cass-operator-manifests.yaml

kubectl create secret generic cassandra-admin-secret -n cass-operator \
	--from-literal=username=cassandra-admin \
	--from-literal=password=cassandra-admin-password
	
kubectl get pods -n cass-operator -w
