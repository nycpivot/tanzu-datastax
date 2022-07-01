#!/bin/bash

kubectl config get-contexts

read -p "Context: " context

kubectl config use-context $context

bash cass-operator/01-cass-operator-prereqs.sh
bash cass-operator/12-cass-operator-multi-zone-setup-3.11.7.sh
