* reconfigure to allow automatically approve for new nodes. 
* update in inventory.cfg
# https://access.redhat.com/articles/3716881
openshift_master_bootstrap_auto_approve=true 

* bootstrap openshift 3.x
$ make openshift 

* after completed, check host zones and records.
$ awless list zones

|            ID ▲            |       NAME       |            COMMENT             | PRIVATE | NB RECORDS |           CALLERREFERENCE            |
|----------------------------|------------------|--------------------------------|---------|------------|--------------------------------------|
| /hostedzone/Z3KKPGMUMA08H5 | openshift.local. | OpenShift Cluster Internal DNS | true    | 5          | terraform-20190709013543910700000001 |

$ awless list records

|  AWLESSID ▲   | TYPE |          NAME           |            RECORDS             |       ZONE       | ALIAS |  TTL   |
|---------------|------|-------------------------|--------------------------------|------------------|-------|--------|
| awls-44e106d9 | NS   | openshift.local.        | ns-1536.awsdns-00.co.uk.       | openshift.local. |       | 172800 |
|               |      |                         | ns-0.awsdns-00.com.            |                  |       |        |
|               |      |                         | ns-1024.awsdns-00.org.         |                  |       |        |
|               |      |                         | ns-512.awsdns-00.net.          |                  |       |        |
| awls-4c02071b | SOA  | openshift.local.        | ns-1536.awsdns-00.co.uk.       | openshift.local. |       | 900    |
|               |      |                         | awsdns-hostmaster.amazon.com.  |                  |       |        |
|               |      |                         | 1 7200 900 1209600 86400       |                  |       |        |
| awls-6864087e | A    | node1.openshift.local.  | 172.10.1.240                   | openshift.local. |       | 300    |
| awls-6877087f | A    | node2.openshift.local.  | 172.10.1.28                    | openshift.local. |       | 300    |
| awls-77ed0933 | A    | master.openshift.local. | 172.10.1.225                   | openshift.local. |       | 300    |


* if you cannot access via ssh, run these steps.
cat ./scripts/postinstall-master.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh master.openshift.local
cat ./scripts/postinstall-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh node1.openshift.local
cat ./scripts/postinstall-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh node2.openshift.local

* keep the terraform state clean.
terraform validate && terraform plan && terraform apply -auto-approve

* login to master.
$ make ssh-master

* edit config inventory.cfg and reconfigure openshift.
$ make ssh-bastion

ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/prerequisites.yml
ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/deploy_cluster.yml

- Promote admin user to access cluster console device.
http://blog.andyserver.com/2018/10/enabling-the-openshift-cluster-console-in-minishift/

make ssh-master
oc login -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin
oc adm policy add-cluster-role-to-user cluster-monitoring-view admin

- switching over PVC storage persistance GP2.
https://docs.openshift.com/container-platform/3.11/install_config/registry/deploy_registry_existing_clusters.html#registry-production-use
https://docs.openshift.com/container-platform/3.11/install_config/persistent_storage/index.html#install-config-persistent-storage-index

$ oc get pvc
NAME               STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
registry-storage   Bound     pvc-65f934cf-b359-11e9-8849-026f8b0bbf30   20Gi       RWO            gp2            5d

oc set volume deploymentconfigs/docker-registry --add \
   --name=registry-storage -t pvc \
   --claim-name=registry-storage --overwrite
