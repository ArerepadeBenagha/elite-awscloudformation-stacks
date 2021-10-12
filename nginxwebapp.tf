###########------ Nginx Server -----########
resource "aws_instance" "nginxserver" {
  ami = lookup(var.ami, var.aws_region)
  # ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.private-subnet-2.id
  key_name               = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [data.aws_security_group.webserver-sg.id]

  # connection {
  #   # The default username for our AMI
  #   user        = "ubuntu"
  #   host        = self.public_ip
  #   type        = "ssh"
  #   private_key = file(var.path)
  # }
  # # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get -y update",
  #     "sudo apt install nginx -y",
  #     # "sudo apt install apache2 -y",
  #     # "sudo systemctl start apache2",
  #   ]
  # }
  tags = merge(local.common_tags,
    { Name = "nginx-server"
  Application = "public" })
}