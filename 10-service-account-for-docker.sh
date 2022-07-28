#!/bin/bash

read -p "Docker Password: " docker_password

kubectl config get-contexts

read -p "Context: " context

kubectl config use-context $context

kubectl create secret docker-registry registrykey --docker-server=index.docker.io \
        --docker-username=nycpivot --docker-password=$docker_password
				
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "registrykey"}]}'

