# /////////////////////// creating the RDS instance ////////////////////////////
resource "aws_db_subnet_group" "my-subnet-gp" {
  name       = "main-subnet-gp"
  subnet_ids = var.subnet-ids
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.my-subnet-gp.name
  vpc_security_group_ids = var.sg-id-list
  skip_final_snapshot    = true         # for dev in prod set to false 
}

# /////////////////////// creating the elascticache instance ////////////////////////////

resource "aws_elasticache_serverless_cache" "redis" {
  engine = "redis"
  name   = var.redis-name
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  daily_snapshot_time      = "09:00"
  description              = "redis Server"
  kms_key_id               = aws_kms_key.my-key.arn
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids       = var.sg-id-list
  subnet_ids               = var.subnet-ids
}

#   /////////////////////// creating the KMS key for redis instance ////////////////////////////
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "my-key" {
  description             = "An example symmetric encryption KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/salma"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/salma"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/salma"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}
