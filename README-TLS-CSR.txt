https://access.redhat.com/solutions/3716861

- manual approve CSR.
# approve all pending status CSR.
oc get csr -o name | xargs oc adm certificate approve

# check openshift node service and health status.
systemctl status atomic-openshift-node (openshift enterprise)
systemctl status origin-node (openshift OKD)

oc get --raw /api/v1/nodes/${NAME}/proxy/healthz

# alternative to check all
$ oc get nodes
NAME                                              STATUS    ROLES          AGE       VERSION
ip-172-10-1-198.ap-southeast-1.compute.internal   Ready     infra,master   1h        v1.11.0+d4cacc0
ip-172-10-1-223.ap-southeast-1.compute.internal   Ready     compute        11m       v1.11.0+d4cacc0

for i in $(oc get nodes --no-headers -o=custom-columns=NAME:.metadata.name); do 
  printf "${i}\n"; oc get --raw /api/v1/nodes/${i}/proxy/healthz ; printf "\n"; 
done;

ip-172-10-1-198.ap-southeast-1.compute.internal
ok
ip-172-10-1-223.ap-southeast-1.compute.internal
ok

- manual TLS reset.
* on master
oc serviceaccounts create-kubeconfig node-bootstrapper -n openshift-infra --config /etc/origin/master/admin.kubeconfig > ~/bootstrap.kubeconfig

* on node
cp ~/bootstrap.config -> node:/etc/origin/node/
mv /etc/origin/node/client-ca.crt{,.old}
mv /etc/origin/node/node.kubeconfig{,.old}
rm -rf  /etc/origin/node/certificates

systemctl restart origin-node.service
systemctl status origin-node -l
