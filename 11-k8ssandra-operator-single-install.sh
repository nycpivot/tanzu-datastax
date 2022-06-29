#!/bin/bash

kubectl config get-contexts

read -p "Context: " context

kubectl config use-context $context

bash k8ssandra/01-k8ssandra-operator-prereqs.sh
bash k8ssandra/11-k8ssandra-single-zone-setup.sh
