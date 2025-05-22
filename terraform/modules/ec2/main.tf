# -------------------------------------------
# |                                          | 
# |               get ami id                 |
# |                                          |
# -------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# -------------------------------------------
# |                                          | 
# |               create EC2                 |
# |                                          |
# -------------------------------------------
resource "aws_instance" "my-ec2" {
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.my_key
  instance_type               = var.instance-type
  subnet_id                   = var.subnet-id
  associate_public_ip_address = var.isPublic == "public" ? true : false
  vpc_security_group_ids      = [var.security-group-id]
  tags                        = var.tags
}

