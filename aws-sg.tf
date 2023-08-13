######
# Security Group Port Rules
######

variable "alb-port-list" {
  type = map(any)
  default = {
    "http"  = 80
    "https" = 443

  }
}

variable "bastion-host-port-list" {
  type = map(any)
  default = {
    "http"  = 80
    "https" = 443
    "ssh"   = 22
  }
}

variable "application-port-list" {
  type = map(any)
  default = {
    "http"  = 80
    "https" = 443
    "ssh"   = 22
  }
}

variable "data-port-list" {
  type = map(any)
  default = {
    "http"  = 80
    "https" = 443
    "ssh"   = 22
  }
}



######
# Security Group Resources
######

# ALB Security Group
resource "aws_security_group" "alb-sg" {
  name        = format("%s-%s-alb-sg", var.project, var.environment)
  description = format("%s-%s-alb-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.alb-port-list
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [
      "0.0.0.0/0"]
      description = ingress.key
    }
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-alb-sg", var.project, var.environment),
  })
  lifecycle { create_before_destroy = true }

}


resource "aws_security_group" "bastion-host-sg" {
  name        = format("%s-%s-bastion-host-sg", var.project, var.environment)
  description = format("%s-%s-bastion-host-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.bastion-host-port-list
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [
      "0.0.0.0/0"]
      description = ingress.key
    }
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-bastion-host-sg", var.project, var.environment),
  })
  lifecycle { create_before_destroy = true }

}
# Application Security Group
resource "aws_security_group" "application-sg" {
  name        = format("%s-%s-application-sg", var.project, var.environment)
  description = format("%s-%s-application-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.application-port-list
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.key
    }
  }


  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = {
    Name        = format("%s-%s-app-sg", var.project, var.environment)
    ENVIRONMENT = var.environment
  }
  lifecycle { ignore_changes = [ingress, egress] }

}

# Data Security Group
resource "aws_security_group" "data-sg" {
  name        = format("%s-%s-data-sg", var.project, var.environment)
  description = format("%s-%s-data-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.data-port-list
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.key
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = {
    Name        = format("%s-%s-data-sg", var.project, var.environment)
    ENVIRONMENT = var.environment
  }
  lifecycle { ignore_changes = [ingress, egress] }
}




variable "whitelist-database" {
  type    = list(string)
  default = []
}
variable "mongo-database" {
  type    = list(string)
  default = ["172.50.0.64/27"]
}



##############
# Mongo SG
#############
variable "mongo-port" {
  type = map(any)
  default = {
    "redis" = 27017
  }
}

resource "aws_security_group" "mongo-sg" {
  name        = format("%s-%s-mongo-sg", var.project, var.environment)
  description = format("%s-%s-mongo-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.mongo-port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.mongo-database
      description = ingress.key
    }
  }
  ingress {
    from_port   = -1
    protocol    = "icmp"
    to_port     = -1
    cidr_blocks = ["172.50.0.64/27"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-mongo-sg", var.project, var.project),
  })
  lifecycle { ignore_changes = [ingress] }
}


resource "aws_security_group" "gateway01-sg" {
  name        = format("%s-%s-gateway01-sg", var.project, var.environment)
  description = format("%s-%s-gateway01-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.gateway
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      description = ingress.key
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-gateway01-sg", var.project, var.environment),
  })
  lifecycle { ignore_changes = [ingress] }
}

resource "aws_security_group" "gateway02-sg" {
  name        = format("%s-%s-gateway02-sg", var.project, var.environment)
  description = format("%s-%s-gateway02-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.gateway
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      description = ingress.key
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-gateway02-sg", var.project, var.environment),
  })
  lifecycle { ignore_changes = [ingress] }
}

resource "aws_security_group" "mongodb_cluster01-sg" {
  name        = format("%s-%s-mongodb_cluster01-sg", var.project, var.environment)
  description = format("%s-%s-mongodb_cluster01-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.mongodb
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      description = ingress.key
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-mongodb_cluster01-sg", var.project, var.environment),
  })
  lifecycle { ignore_changes = [ingress] }
}

resource "aws_security_group" "mongodb_cluster02-sg" {
  name        = format("%s-%s-mongodb_cluster02-sg", var.project, var.environment)
  description = format("%s-%s-mongodb_cluster02-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.mongodb
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      description = ingress.key
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-mongodb_cluster02-sg", var.project, var.environment),
  })
  lifecycle { ignore_changes = [ingress] }
}

resource "aws_security_group" "mongodb_cluster03-sg" {
  name        = format("%s-%s-mongodb_cluster03-sg", var.project, var.environment)
  description = format("%s-%s-mongodb_cluster03-sg", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = var.mongodb
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
      description = ingress.key
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, {
    Name = format("%s-%s-mongodb_cluster03-sg", var.project, var.environment),
  })
  lifecycle { ignore_changes = [ingress] }
}


resource "aws_elasticache_subnet_group" "memcached" {
  name       = format("%s-%s-memcached-subnet", var.project, var.environment)
  subnet_ids = [module.vpc.intra_subnets[0], module.vpc.intra_subnets[1]]
}

resource "aws_security_group" "memcached" {
  name        = format("%s-%s-memcached", var.project, var.environment)
  description = format("%s-%s-memcached", var.project, var.environment)
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
    description = format("%s-%s-memcached", var.project, var.environment)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = upper(format("%s-%s-memcached", var.project, var.environment)),
  })

}