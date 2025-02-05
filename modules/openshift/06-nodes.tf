//  Create an SSH keypair
resource "aws_key_pair" "keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

//  Create the master userdata script.
data "template_file" "setup-master" {
  template = "${file("${path.module}/files/setup-master.sh")}"
  vars = {
    availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  }
}

// Create Elastic IP for master
resource "aws_eip" "master_eip" {
  instance = "${aws_instance.master.id}"
  vpc      = true
}

//  Launch configuration for the consul cluster auto-scaling group.
resource "aws_instance" "master" {
  ami                  = "${data.aws_ami.rhel7_5.id}"
  # Master nodes require at least 16GB of memory.
  instance_type        = "m4.xlarge"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-master.rendered}"

  lifecycle {
    prevent_destroy = false
  }

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdba"
      encrypted             = true
      iops                  = 100
      volume_size           = 10
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdbg"
      encrypted             = true
      iops                  = 100
      volume_size           = 10
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdbq"
      encrypted             = true
      iops                  = 100
      volume_size           = 10
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdbs"
      encrypted             = false
      iops                  = 100
      volume_size           = 10
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = true
      device_name           = "/dev/sdf"
      encrypted             = false
      iops                  = 240
      volume_size           = 80
      volume_type           = "gp2"
  }

  root_block_device {
      delete_on_termination = true
      iops                  = 150
      volume_size           = 50
      volume_type           = "gp2"
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Master"
    )
  )}"
}

//  Create the node userdata script.
data "template_file" "setup-node" {
  template = "${file("${path.module}/files/setup-node.sh")}"
  vars = {
    availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  }
}

// Create Elastic IP for the nodes
resource "aws_eip" "node1_eip" {
  instance = "${aws_instance.node1.id}"
  vpc      = true
}

resource "aws_eip" "node2_eip" {
  instance = "${aws_instance.node2.id}"
  vpc      = true
}

resource "aws_eip" "node3_eip" {
  instance = "${aws_instance.node3.id}"
  vpc      = true
}

//  Create the two nodes. This would be better as a Launch Configuration and
//  autoscaling group, but I'm keeping it simple...
resource "aws_instance" "node1" {
  ami                  = "${data.aws_ami.rhel7_5.id}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-node.rendered}"

  lifecycle {
    prevent_destroy = false
  }

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  ebs_block_device {
      delete_on_termination = true
      device_name           = "/dev/sdf"
      encrypted             = false
      iops                  = 240
      volume_size           = 80
      volume_type           = "gp2"
  }

  root_block_device {
      delete_on_termination = true
      iops                  = 150
      volume_size           = 50
      volume_type           = "gp2"
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Node 1"
    )
  )}"
}

resource "aws_instance" "node2" {
  ami                  = "${data.aws_ami.rhel7_5.id}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-node.rendered}"

  lifecycle {
    prevent_destroy = false
  }

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdbf"
      encrypted             = false
      iops                  = 100
      volume_size           = 1
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdbw"
      encrypted             = false
      iops                  = 100
      volume_size           = 1
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdcc"
      encrypted             = true
      iops                  = 100
      volume_size           = 10
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdcv"
      encrypted             = false
      iops                  = 100
      volume_size           = 1
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = true
      device_name           = "/dev/sdf"
      encrypted             = false
      iops                  = 240
      volume_size           = 80
      volume_type           = "gp2"
  }

  root_block_device {
      delete_on_termination = true
      iops                  = 150
      volume_size           = 50
      volume_type           = "gp2"
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Node 2"
    )
  )}"
}

resource "aws_instance" "node3" {
  ami                  = "${data.aws_ami.rhel7_5.id}"
  instance_type        = "${var.amisize}"
  subnet_id            = "${aws_subnet.public-subnet.id}"
  iam_instance_profile = "${aws_iam_instance_profile.openshift-instance-profile.id}"
  user_data            = "${data.template_file.setup-node.rendered}"

  lifecycle {
    prevent_destroy = false
  }

  vpc_security_group_ids = [
    "${aws_security_group.openshift-vpc.id}",
    "${aws_security_group.openshift-public-ingress.id}",
    "${aws_security_group.openshift-public-egress.id}",
  ]

  ebs_block_device {
      delete_on_termination = false
      device_name           = "/dev/xvdcw"
      encrypted             = true
      iops                  = 100
      volume_size           = 10
      volume_type           = "gp2"
  }
  ebs_block_device {
      delete_on_termination = true
      device_name           = "/dev/sdf"
      encrypted             = false
      iops                  = 240
      volume_size           = 80
      volume_type           = "gp2"
  }
  root_block_device {
      delete_on_termination = true
      iops                  = 150
      volume_size           = 50
      volume_type           = "gp2"
  }

  key_name = "${aws_key_pair.keypair.key_name}"

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Node 3"
    )
  )}"
}
