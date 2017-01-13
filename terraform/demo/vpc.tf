resource "aws_vpc" "vpc_demo" {
  cidr_block = "${var.base_vpc_cidr}"

  tags = {
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Name        = "vpc_demo_${var.environment}"
  }
}

resource "aws_vpc_endpoint" "private-s3" {
	vpc_id = "${aws_vpc.vpc_demo.id}"
	service_name = "com.amazonaws.eu-central-1.s3"
	route_table_ids = ["${aws_route_table.route_lb2private.id}"]
}
