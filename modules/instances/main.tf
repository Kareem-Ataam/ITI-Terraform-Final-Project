data "aws_ami" "instance_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Amazon

}
resource "aws_key_pair" "ssh-key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}
resource "aws_instance" "public_instance" {
  count                       = length(var.public_subnet_ids)
  ami                         = data.aws_ami.instance_ami.id
  instance_type               = var.public_instance_type
  subnet_id                   = var.public_subnet_ids[count.index]
  vpc_security_group_ids      = [var.public_instance_sg_id]
  key_name                    = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }
  provisioner "file" {
    source      = "E:\\ICC-ITI\\Terraform_LABS\\ITI-Terraform-Final-Project\\scripts\\install-docker.sh"
    destination = "/home/ec2-user/install-docker.sh"
  }
  provisioner "remote-exec" {
    inline = ["chmod +x /home/ec2-user/install-docker.sh", "/home/ec2-user/install-docker.sh"]
  }
  # provisioner "file" {
  #   source      = "../../scripts/nginx-reverse-proxy.sh"
  #   destination = "/home/ec2-user/nginx-reverse-proxy.sh"
  # }
  # provisioner "remote-exec" {
  #   inline = ["chmod +x /home/ec2-user/nginx-reverse-proxy.sh", "/home/ec2-user/nginx-reverse-proxy.sh"]
  # }
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "cat <<EOF > nginx.conf",
      "events {}",

      "http {",
      "server {",
      "listen 80;",
      "server_name _;",

      "location / {",
      "proxy_pass http://${var.private_alb_dns_name};",
      "proxy_set_header Host \\$host;",
      "proxy_set_header X-Real-IP \\$remote_addr;",
      "proxy_set_header X-Forwarded-For \\$proxy_add_x_forwarded_for;",
      "proxy_set_header X-Forwarded-Proto \\$scheme;",
      "}",
      "}",
      "}",
      "EOF",

      "docker run -d --name nginx-reverse-proxy -p 80:80 -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro nginx:latest",
      "echo 'Requests to this EC2 instance on port 80 will be forwarded to: http://${var.private_alb_dns_name}'"
    ]
  }
  provisioner "local-exec" {
    command = "echo Public-IP${(count.index) + 1}: ${self.public_ip} > public_ips.txt"
  }
  tags = {
    Name = "PublicInstance"
  }
}

resource "aws_instance" "private_instance" {
  count                  = length(var.private_subnet_ids)
  ami                    = data.aws_ami.instance_ami.id
  instance_type          = var.private_instance_type
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.private_instance_sg_id]
  key_name               = aws_key_pair.ssh-key.key_name

  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file(var.private_key_path)
    host                = self.private_ip
    bastion_host        = aws_instance.public_instance[0].public_ip
    bastion_user        = "ec2-user"
    bastion_private_key = file(var.private_key_path)
  }
  provisioner "file" {
    source      = "E:\\ICC-ITI\\Terraform_LABS\\ITI-Terraform-Final-Project\\scripts\\install-docker.sh"
    destination = "/home/ec2-user/install-docker.sh"
  }
  provisioner "remote-exec" {
    inline = ["chmod +x /home/ec2-user/install-docker.sh", "/home/ec2-user/install-docker.sh"]
  }
  provisioner "file" {
    source      = "E:\\ICC-ITI\\Terraform_LABS\\ITI-Terraform-Final-Project\\flask_app\\"
    destination = "/home/ec2-user/flask_app"
  }
  provisioner "remote-exec" {
    inline = ["chmod +x /home/ec2-user/flask_app/run_app_container.sh", "cd /home/ec2-user/flask_app", "./run_app_container.sh"]
  }
  tags = {
    Name = "PrivateInstance"
  }
}
