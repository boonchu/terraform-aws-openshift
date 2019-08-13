# pull state output to temporary file.
terraform state pull > /tmp/manual-import.tfstate

# for instance, use node2 to run terraform change.
# update 'life cycle'.
# https://www.hashicorp.com/blog/zero-downtime-updates-with-terraform

  lifecycle {
    prevent_destroy = true
  }

# refresh
terraform refresh

# capture changes from current state.
terraform state show module.openshift.aws_instance.node2

# run 'plan' for specific module.
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
