kubectl get pods -n cass-operator

read -p "Select pod: " pod

kubectl exec $pod cassandra -it -n cass-operator -- cqlsh -u cassandra-admin -p cassandra-admin-password

