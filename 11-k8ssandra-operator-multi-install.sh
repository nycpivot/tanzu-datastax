#!/bin/bash

kubectl config get-contexts

read -p "Context: " context

kubectl config use-context $context

bash k8ssandra/01-k8ssandra-operator-prereqs.sh
bash k8ssandra/12-k8ssandra-multi-zone-setup.sh
