#  ------------------------------------------
# |                                          | 
# |               Create VPC                 |
# |                                          |
#  ------------------------------------------

module "vpc" {
  source   = "./modules/vpc"
  region   = var.aws-region
  vpc-cidr = var.vpc-cidr
  subnets  = var.subnets
}

#  ------------------------------------------
# |                                          | 
# |         create Security Groups           |
# |                                          |
#  ------------------------------------------

module "public-sg" {
  source      = "./modules/security-groups"
  name        = "public-SG"
  description = "Public Security Group"
  vpc_id      = module.vpc.vpc-id
  ingress_rules = {
    http = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
    ssh = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 22
      ip_protocol                  = "tcp"
      to_port                      = 22
    }
    jenkins = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 8080
      ip_protocol                  = "tcp"
      to_port                      = 8080
    }
  }

  tags = {
    Name = "public-SG"
  }
}

module "private-sg" {
  source      = "./modules/security-groups"
  name        = "private-SG"
  description = "private Security Group"
  vpc_id      = module.vpc.vpc-id
  ingress_rules = {
    http = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.alb-sg.sg_id
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
    ssh = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.public-sg.sg_id
      from_port                    = 22
      ip_protocol                  = "tcp"
      to_port                      = 22
    }
  }

  tags = {
    Name = "private-SG"
  }
}

#  ------------------------------------------
# |                                          | 
# |              create Ec2                  |
# |                                          |
#  ------------------------------------------

# ////////////////////// Key Pair /////////////////////////
resource "aws_key_pair" "my_key" {
  key_name   = "mykey"
  public_key = file(var.public_key_path)
}

# ////////////////////// Bastion Host /////////////////////

module "Bastion-host" {
  source            = "./modules/ec2"
  my_key            = aws_key_pair.my_key.key_name
  instance-type     = var.instance-type
  subnet-id         = module.vpc.public-subnet-id-1
  security-group-id = module.public-sg.sg_id
  isPublic          = "public"
  tags = {
    Name = "Bastion Host"
  }
}

# ///////////////////// Jenkins Slave /////////////////////

module "jenkins-slave" {
  source            = "./modules/ec2"
  my_key            = aws_key_pair.my_key.key_name
  instance-type     = var.instance-type
  subnet-id         = module.vpc.private-subnet-id-1
  security-group-id = module.private-sg.sg_id
  isPublic          = "private"
  tags = {
    Name = "Jenkins Slave"
  }
}

# ///////////////////// Node instances /////////////////////

module "node-app-1" {
  source            = "./modules/ec2"
  my_key            = aws_key_pair.my_key.key_name
  instance-type     = var.instance-type
  subnet-id         = module.vpc.private-subnet-id-1
  security-group-id = module.private-sg.sg_id
  isPublic          = "private"
  tags = {
    Name = "App server 1"
  }
}

module "node-app-2" {
  source            = "./modules/ec2"
  my_key            = aws_key_pair.my_key.key_name
  instance-type     = var.instance-type
  subnet-id         = module.vpc.private-subnet-id-2
  security-group-id = module.private-sg.sg_id
  isPublic          = "private"
  tags = {
    Name = "App server 2"
  }
}

#  ------------------------------------------
# |                                          | 
# |              create ALB                  |
# |                                          |
#  ------------------------------------------

# ///////////////////// Alb security group ///////////////////// 
module "alb-sg" {
  source      = "./modules/security-groups"
  name        = "alb-SG"
  description = "application loadbalancer Security Group"
  vpc_id      = module.vpc.vpc-id

  ingress_rules = {
    http = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80

    }
  }

}

# ///////////////////// Alb ///////////////////// 
module "my-alb" {
  source               = "./modules/ALB"
  alb-name             = "generalalb"
  isInternal           = false
  security-group-ids   = [module.alb-sg.sg_id]
  subnet-ids           = [module.vpc.public-subnet-id-1, module.vpc.public-subnet-id-2]
  vpc-id               = module.vpc.vpc-id
  target-gp-name       = "nodeApp-target-group"
  target-group-list-id = { "node app 1" = module.node-app-1.instance-id, "node app 2" = module.node-app-2.instance-id }
}

#  ------------------------------------------
# |                                          | 
# |             create Databases             |
# |                                          |
#  ------------------------------------------
# ////////////////////////// Databases security groups ///////////////
module "db-sg" {
  source      = "./modules/security-groups"
  name        = "db-SG"
  description = "databases Security Group"
  vpc_id      = module.vpc.vpc-id

  ingress_rules = {
    mysql = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.private-sg.sg_id
      from_port                    = 3306 # mySQL port 
      ip_protocol                  = "tcp"
      to_port                      = 3306

    }
    redis = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.private-sg.sg_id
      from_port                    = 6379 # Redis port 
      ip_protocol                  = "tcp"
      to_port                      = 6379

    }
  }

}
#////////////////////// create the  databases /////////////////////
module "databases" {
  source      = "./modules/database"
  subnet-ids  = [module.vpc.private-subnet-id-1, module.vpc.private-subnet-id-2]
  sg-id-list  = [module.db-sg.sg_id]
  db_username = var.db_username
  db_password = var.db_password
  redis-name  = "my-redis"
}
