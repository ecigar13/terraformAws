provider "aws" {
 region = "${var.region}"
 version = "~> 1.19"
 access_key = "${var.aws_access_key}"
 secret_key = "${var.aws_secret_key}"
}

resource "aws_instance" "myapp_ec2_instance" {
 ami               = "ami-21f78e11"
 availability_zone = "${var.availability_zone}"
 instance_type     = "${var.instance_type}"

 tags {
   Name = "myapp-EC2-instance"
 }
}

resource "aws_ebs_volume" "myapp_ebs_volume" {
 availability_zone = "${var.availability_zone}"
 size              = 1

  tags {
   Name = "myapp-EBS-volume"
 }
}

resource "aws_volume_attachment" "myapp_vol_attachment" {
 device_name = "/dev/sdh"
 volume_id   = "${aws_ebs_volume.myapp_ebs_volume.id}"
 instance_id = "${aws_instance.myapp_ec2_instance.id}"
}

data "aws_route53_zone" "myapp_private_hosted_zone" {
 vpc_id       = "${var.myapp_vpc.id}"
 name         = "${var.private_hosted_zone_name}"
 private_zone = true
}

resource "aws_eip" "myapp_eip" {
 instance = "${aws_instance.myapp_ec2_instance.id}"
 vpc      = true
}

resource "aws_route53_record" "myapp_hosted_zone_entry" {
 zone_id = "${data.aws_route53_zone.myapp_private_hosted_zone.id}"
 name    = "subdomain.myapp"
 type    = "A"
 ttl     = "300"
 records = ["${aws_eip.myapp_eip.public_ip}"]
}
