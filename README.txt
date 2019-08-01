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

$ make openshift 
cat ./scripts/postinstall-master.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh master.openshift.local
cat ./scripts/postinstall-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh node1.openshift.local
cat ./scripts/postinstall-node.sh | ssh -A ec2-user@$(terraform output bastion-public_ip) ssh node2.openshift.local

$ make ssh-master

- edit config inventory.cfg
$ make ssh-bastion

ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/prerequisites.yml
ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/deploy_cluster.yml

- Promote admin user to access cluster console device.
http://blog.andyserver.com/2018/10/enabling-the-openshift-cluster-console-in-minishift/

oc login -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin
oc adm policy add-cluster-role-to-user cluster-monitoring-view admin
