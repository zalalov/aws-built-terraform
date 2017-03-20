# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

/*
 *Elastic IPs
 */

# admim app eip
resource "aws_eip" "admin_app_eip" {
  vpc = true
  instance = "${aws_instance.provectus_test_admin_app.id}"
}

# blog app eip
resource "aws_eip" "blog_app_eip" {
  vpc = true
  instance = "${aws_instance.provectus_test_blog_app.id}"
}

# proxy app eip
resource "aws_eip" "proxy_eip" {
  vpc = true
  instance = "${aws_instance.provectus_test_proxy.id}"
}

# redis eip
resource "aws_eip" "redis_eip" {
  vpc = true
  instance = "${aws_instance.provectus_test_redis.id}"
}

# monitoring server eip
resource "aws_eip" "monitor_eip" {
  vpc = true
  instance = "${aws_instance.provectus_test_monitor.id}"
}

/*
 * Security Groups
 */

# security group for proxy instance
resource "aws_security_group" "provectus_test_sg_proxy" {
  name = "provectus_test_sg_proxy"
  description = "proxy instance security group"

  # inbound connections
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound connections
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group for admin app instance
resource "aws_security_group" "provectus_test_sg_admin_app" {
  name = "provectus_test_sg_admin_app"
  description = "admin app instance security group"

  # inbound connections
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.provectus_test_sg_proxy.id}"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.provectus_test_sg_proxy.id}"]
  }

  # outbound connections
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group for blog app instance
resource "aws_security_group" "provectus_test_sg_blog_app" {
  name = "provectus_test_sg_blog_app"
  description = "blog app instance security group"

  # inbound connections
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.provectus_test_sg_proxy.id}"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.provectus_test_sg_proxy.id}"]
  }

  # outbound connections
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group for redis server instance
resource "aws_security_group" "provectus_test_sg_redis" {
  name = "provectus_test_sg_redis"
  description = "redis server instance security group"

  # inbound connections
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.provectus_test_sg_proxy.id}",
      "${aws_security_group.provectus_test_sg_admin_app.id}",
      "${aws_security_group.provectus_test_sg_blog_app.id}"
    ]
  }

  # outbound connections
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group for monitoring server instance
resource "aws_security_group" "provectus_test_sg_monitor" {
  name = "provectus_test_sg_monitor"
  description = "monitoring server instance security group"

  # inbound connections
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 10050
    to_port = 10050
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.provectus_test_sg_proxy.id}",
      "${aws_security_group.provectus_test_sg_admin_app.id}",
      "${aws_security_group.provectus_test_sg_redis.id}",
      "${aws_security_group.provectus_test_sg_blog_app.id}",
    ]
  }

  # outbound connections
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group for rds instance
resource "aws_security_group" "provectus_test_sg_db" {
  name = "provectus_test_sg_db"
  description = "rds instance security group"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.provectus_test_sg_admin_app.id}",
      "${aws_security_group.provectus_test_sg_blog_app.id}"
    ]
  }

  # outbound connections
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

/**
 * EC2 instances
 */

# blog app instance
resource "aws_instance" "provectus_test_proxy" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # Our Security group to allow SSH access
  security_groups = ["${aws_security_group.provectus_test_sg_proxy.name}"]
  key_name = "${var.aws_keypair_name}"

  #Instance tags
  tags {
    Name = "provectus_test_proxy"
  }
}

# admin app instance
resource "aws_instance" "provectus_test_admin_app" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.provectus_test_sg_admin_app.name}"]
  key_name = "${var.aws_keypair_name}"

  #Instance tags
  tags {
    Name = "provectus_test_admin_app"
  }
}

# blog app instance
resource "aws_instance" "provectus_test_blog_app" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # Our Security group to allow SSH access
  security_groups = ["${aws_security_group.provectus_test_sg_blog_app.name}"]
  key_name = "${var.aws_keypair_name}"

  #Instance tags
  tags {
    Name = "provectus_test_blog_app"
  }
}

# redis service instance
resource "aws_instance" "provectus_test_redis" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # Our Security group to allow SSH access
  security_groups = ["${aws_security_group.provectus_test_sg_redis.name}"]
  key_name = "${var.aws_keypair_name}"

  #Instance tags
  tags {
    Name = "provectus_test_redis"
  }
}

# monitoring server instance
resource "aws_instance" "provectus_test_monitor" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # Our Security group to allow SSH access
  security_groups = ["${aws_security_group.provectus_test_sg_monitor.name}"]
  key_name = "${var.aws_keypair_name}"

  #Instance tags
  tags {
    Name = "provectus_test_monitor"
  }
}

/**
 * RDS instance
 */

# rds
resource "aws_db_instance" "provectus-test-db" {
  identifier = "${var.aws_db_config.id}"
  allocated_storage = "${var.aws_db_config.storage}"
  engine = "${var.aws_db_config.engine}"
  engine_version = "${var.aws_db_config.engine_version}"
  instance_class = "${var.aws_db_config.instance_class}"
  name = "${var.aws_db_config.db_name}"
  username = "${var.aws_db_config.username}"
  password = "${var.aws_db_config.password}"
  vpc_security_group_ids = ["${aws_security_group.provectus_test_sg_db.id}"]
}
