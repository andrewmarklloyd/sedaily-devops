resource "aws_instance" "sedaily" {
  provider          = "aws.usw2"
  ami               = "${data.aws_ami.ec2_linux.id}"
  instance_type     = "t2.micro"
  availability_zone = "us-west-2a"
  key_name          = "prod"

  vpc_security_group_ids = ["${aws_security_group.sedaily.id}"]
  subnet_id              = "${aws_subnet.main.id}"

  user_data = "${file("./ec2-user-data.sh")}"
}

resource "aws_volume_attachment" "sedaily" {
  provider    = "aws.usw2"
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.sedaily.id}"
  instance_id = "${aws_instance.sedaily.id}"
}

resource "aws_ebs_volume" "sedaily" {
  provider          = "aws.usw2"
  availability_zone = "us-west-2a"
  size              = 8
}
