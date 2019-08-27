Option 1:
./refresh on   : turn on terraform update.
./refresh off  : turn off terraform update.

Option 2:
# pull state output to temporary file.
terraform state pull > /tmp/manual-import.tfstate

# for instance, use node2 to run terraform change.
# update 'life cycle'.
# https://www.hashicorp.com/blog/zero-downtime-updates-with-terraform
# switch on/off from boolean value.
  lifecycle {
    prevent_destroy = true
  }

# refresh when changes in code applied.
terraform refresh
# capture changes from current state.
terraform state show module.openshift.aws_instance.node2
# * copy change from 'state show' to update code in modules.
# * run 'terraform refresh'
# * run 'plan' for specific module.
terraform plan -target=module.openshift.aws_instance.node2


# add new nodes 'node3'.
* insert resoruce aws_instance and eip of node3.
modules/openshift/06-nodes.tf
modules/openshift/07-dns.tf
modules/openshift/09-inventory.tf
modules/openshift/99-outputs.tf

* update new node name to inventory template config file.
inventory.template.cfg

* run plan, apply and refresh
terraform refresh
terraform plan -target=module.openshift.aws_instance.node3
terraform apply -auto-approve -target=module.openshift.aws_instance.node3

* update template inventory.template.cfg to append new node hostname.
