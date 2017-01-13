resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc_demo.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc_demo.cidr_block, 4, 4)}"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "public subnet for LB demo"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_demo.id}"
}

resource "aws_route_table" "route_lb2private" {
  vpc_id = "${aws_vpc.vpc_demo.id}"

  tags = {
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Name        = "route_admin_lb"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.route_lb2private.id}"
}

resource "aws_route" "internet_access_public_subnet" {
  route_table_id         = "${aws_route_table.route_lb2private.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "pr_subnet_association" {
  subnet_id      = "${aws_subnet.subnet_demo_private.id}"
  route_table_id = "${aws_route_table.route_lb2private.id}"
}
