resource "aws_subnet" "subnet_demo_private" {
  vpc_id            = "${aws_vpc.vpc_demo.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc_demo.cidr_block, 4, 6)}"
  availability_zone = "${var.availability_zone}"

  tags = {
    Environment = "${var.environment}"
    Service     = "${var.service}"
    Name        = "demo_private_subnet"
  }
}

data "aws_ami" "demo_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["nginx"]
  }
  filter {
    name = "owner-id"
    values = ["674064483695"]
  }
  filter {
    name = "manifest-location"
    values = ["674064483695/nginx"]
  }
}

# generate SSH key
resource "tls_private_key" "demo_instance" {
        count = "${var.instances}"
        algorithm = "RSA"
        rsa_bits = 4096
}

# put SSH key on AWS
resource "aws_key_pair" "demo_instance" {
	count = "${var.instances}"
  key_name = "demo_instance_${base64sha256(element(tls_private_key.demo_instance.*.private_key_pem, count.index))}"
  public_key = "${element(tls_private_key.demo_instance.*.public_key_openssh, count.index)}"
}

resource "aws_instance" "demo_instance" {
	depends_on = [
		"aws_s3_bucket_object.image",
		"aws_s3_bucket_object.index"
	]
  count                  = "${var.instances}"
  ami                    = "${data.aws_ami.demo_ami.id}"
  instance_type          = "${var.demo_instance_type}"
  key_name               = "${element(aws_key_pair.demo_instance.*.key_name, count.index)}"
  subnet_id              = "${aws_subnet.subnet_demo_private.id}"
  vpc_security_group_ids = ["${aws_security_group.security_group_demo.id}"]
  iam_instance_profile	 = "${aws_iam_instance_profile.s3_read_profile.id}"
	user_data							 = "TMPL_TEXT=${count.index}; AWS_BUCKET=${aws_s3_bucket.demo_bucket.bucket}"

	root_block_device {
		delete_on_termination = true
	}

  tags {
    Name        = "Demo_${count.index}"
    Environment = "${var.environment}"
    Service     = "${var.service}"
  }
}
