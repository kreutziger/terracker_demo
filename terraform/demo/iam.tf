resource "aws_iam_instance_profile" "s3_read_profile" {
	name = "demo_s3_read_profile_${var.environment}"
	roles = [
		"${aws_iam_role.s3_role_read.name}"
	]
}

resource "aws_iam_role" "s3_role_read" {
	name = "demo_s3_role_read_${var.environment}"
	assume_role_policy = "${data.aws_iam_policy_document.assume_policy.json}"
}

data "aws_iam_policy_document" "assume_policy" {
	statement {
		effect = "Allow"
		actions = ["sts:AssumeRole"]
		principals {
			type = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

resource "aws_iam_role_policy" "s3_policy_read" {
	name = "demo_s3_policy_read_${var.environment}"
	role = "${aws_iam_role.s3_role_read.id}"
	policy = "${data.aws_iam_policy_document.read_policy.json}"
}

data "aws_iam_policy_document" "read_policy" {
	statement {
		effect = "Allow"
		actions = [
			"s3:GetObject"
		]
		resources = ["${aws_s3_bucket.demo_bucket.arn}/*"]
	}

	statement {
		effect = "Allow"
		actions = ["s3:ListBucket"]
		resources = ["${aws_s3_bucket.demo_bucket.arn}"]
	}
}
