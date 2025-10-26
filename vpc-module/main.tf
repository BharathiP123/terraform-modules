resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
        Name = local.common_name_suffix
    }
  )
  }

  ##internet gateway creation and attachment
  resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.ig_tags,
    local.common_tags,
    {
        Name = local.common_name_suffix
    }
  )
  }

  ##Public subnet creation 

  resource "aws_subnet" "pbulicsubnets" {
  count = length(var.public_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidrs[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.public_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-publicsubnet-${local.azs[count.index]}" ## roboshop-dev-us-east-1a
    }
  )
}

##private subnet creation 

  resource "aws_subnet" "private_subnets" {
  count = length(var.private_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidrs[count.index]
  availability_zone = local.azs[count.index]
  

  tags = merge(
    var.private_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-privatesubnet-${local.azs[count.index]}" ## roboshop-dev-us-east-1a
    }
  )
}

##database subnet creation 

  resource "aws_subnet" "databasesubnets" {
  count = length(var.database_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidrs[count.index]
  availability_zone = local.azs[count.index]
  

  tags = merge(
    var.database_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-dtabasesubnet-${local.azs[count.index]}" ## roboshop-dev-us-east-1a
    }
  )
}

###Public Route Table creation 
resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.public_routetable_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-publicroute" ## roboshop-dev-us-east-1a
    }
  )
}
###privaterouttable
resource "aws_route_table" "private_routetable" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.private_routetable_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-privateroute" ## roboshop-dev-us-east-1a
    }
  )
}
###Database routable
resource "aws_route_table" "database_routetable" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.database_routetable_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-databaseroute" ## roboshop-dev-us-east-1a
    }
  )
}


### apublic route 

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public_routetable.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

# Elastic IP
resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-nat"
    }
  )
}

### Nat gateway creation
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pbulicsubnets[0].id
  tags = merge(
    var.nat_tags,
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-nat"
    }
  )


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


## nat association to private route
# Private egress route through NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

##Natgateway association for dtabase subnet routes
resource "aws_route" "database_nat_gateway" {
  route_table_id         = aws_route_table.database_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}


## Attach or assoicate the public subnets to pubic routes
resource "aws_route_table_association" "publicsubnet_assoication" {
 count = length(var.public_cidrs)
 subnet_id = aws_subnet.pbulicsubnets[count.index].id
 route_table_id = aws_route_table.public_routetable.id
}

resource "aws_route_table_association" "privatesubnet_associat" {
 count = length(var.private_cidrs)
 subnet_id = aws_subnet.private_subnets[count.index].id
 route_table_id = aws_route_table.private_routetable.id
}

resource "aws_route_table_association" "databasesubnet_associat" {
 count = length(var.database_cidrs)
 subnet_id = aws_subnet.databasesubnets[count.index].id
 route_table_id = aws_route_table.database_routetable.id
}

resource "aws_ssm_parameter" "vpcid_ssm" {
  name  = "/${var.project}/${var.environment}/vpcid_ssm"
  type  = "String"
  value = aws_vpc.main.id
}
##storing the public subnet id's
resource "aws_ssm_parameter" "publich_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_sub_ids"
  type  = "StringList"
  value = join("," ,aws_subnet.pbulicsubnets)
}

##storing the private subnet id's in ssm
resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project}/${var.environment}/private_sub_ids"
  type  = "StringList"
  value = join("," ,aws_subnet.private_subnets)
}
###storing thee database subnet id's in ssm
resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project}/${var.environment}/database_sub_ids"
  type  = "StringList"
  value = join("," ,aws_subnet.aws_subnet.databasesubnets)
}
