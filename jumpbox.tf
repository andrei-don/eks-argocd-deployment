resource "aws_instance" "jumpbox" {
  vpc_security_group_ids = [aws_security_group.instances.id]
  subnet_id              = aws_subnet.private[1].id
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t2.micro"
  user_data              = filebase64("${path.module}/userdata.sh")
}