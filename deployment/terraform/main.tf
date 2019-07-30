resource "aws_instance" "sedaily" {
  provider          = "aws.usw2"
  ami               = "${data.aws_ami.ec2_linux.id}"
  instance_type     = "t2.micro"
  availability_zone = "us-west-2a"
  key_name          = "prod"

  vpc_security_group_ids = ["${aws_security_group.sedaily.id}"]
  subnet_id              = "${aws_subnet.main.id}"

  root_block_device {
    volume_size = 8
  }

  user_data = "${file("./ec2-user-data.sh")}"
}
