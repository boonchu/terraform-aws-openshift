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
