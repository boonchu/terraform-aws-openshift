oc run etcdclient --image=busybox busybox --restart=Never -- /usr/bin/tail -f /dev/null

oc rsh etcdclient

wget https://github.com/coreos/etcd/releases/download/v3.1.4/etcd-v3.1.4-linux-amd64.tar.gz
tar -xvf etcd-v3.1.4-linux-amd64.tar.gz
cp etcd-v3.1.4-linux-amd64/etcdctl .

export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=vault-service-etcd-client:2379

./etcdctl put operator sdk
./etcdctl get operator
exit
