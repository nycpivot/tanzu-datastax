#!/bin/bash

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml

kubectl create namespace k8ssandra

kubectl create secret generic cassandra-admin-secret -n k8ssandra \
	--from-literal=username=cassandra-admin \
	--from-literal=password=cassandra-admin-password
