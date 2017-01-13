resource "aws_elb" "demo_elb" {
  listener {
    instance_port     = 22
    instance_protocol = "TCP"
    lb_port           = 22
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  name = "LB-${var.environment}-demo-elb"
  connection_draining = true
  connection_draining_timeout = 300
  cross_zone_load_balancing = false
  idle_timeout = 60
  security_groups = ["${aws_security_group.security_group_demo.id}"]
  subnets = ["${aws_subnet.public_subnet.id}"]

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:22"
    interval            = 30
  }

  tags = {
    Environment = "${var.environment}"
    Service     = "${var.service}"
  }
}

resource "aws_elb_attachment" "lb_attachment" {
	count = "${var.instances}"
  elb      = "${aws_elb.demo_elb.id}"
  instance = "${element(aws_instance.demo_instance.*.id, count.index)}"
}

resource "aws_security_group" "security_group_demo" {
  name = "security_group_lb_${var.environment}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Environment = "${var.environment}"
    Name        = "security_group_allow_demo_${var.environment}"
  }

  vpc_id = "${aws_vpc.vpc_demo.id}"
}
