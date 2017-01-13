resource "aws_s3_bucket" "demo_bucket" {
  acl    = "private"
  bucket = "cinteo-meetup-demo-${var.environment}"

  tags {
    Name        = "demo-bucket-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_object" "index" {
	bucket = "${aws_s3_bucket.demo_bucket.bucket}"
	key = "index.html"
	source = "index.html"
	content_type = "text/html"
	content_encoding = "utf8"
}

resource "aws_s3_bucket_object" "image" {
	bucket = "${aws_s3_bucket.demo_bucket.bucket}"
	key = "image.png"
	source = "image.png"
	content_type = "image/png"
}
