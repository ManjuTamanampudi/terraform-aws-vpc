resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = local.final_vpc_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

 tags = local.final_igw_tags
}

# public subnet
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block[count.index]
  availability_zone= local.azs_info[count.index]
  map_public_ip_on_launch = "true"

  tags= merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-public-${local.azs_info[count.index]}",
        },
    var.public_subnet_tags    
  )
}
# private subnet
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block[count.index]
  availability_zone= local.azs_info[count.index]

  tags= merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-private-${local.azs_info[count.index]}",
        },
    var.private_subnet_tags    
  )
}
# db subnet
resource "aws_subnet" "db" {
    count = length(var.db_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.db_subnet_cidr_block[count.index]
  availability_zone= local.azs_info[count.index]

  tags= merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-db-${local.azs_info[count.index]}",
        },
    var.db_subnet_tags    
  )
}
# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-public",
        },
    var.public_route_table_tags    
  )
}
#private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-private",
        },
    var.private_route_table_tags    
  )
}

#db route table
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-db",
        },
    var.db_route_table_tags    
  )
}
resource "aws_eip" "nat" {
  domain   = "vpc"
  tags = merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-nat"
        },
    var.eip_tags
  )
}
# nat gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}"
        },
    var.nat_gateway_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id  = aws_internet_gateway.main.id
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}
resource "aws_route" "db" {
  route_table_id            = aws_route_table.db.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db" {
    count = length(var.db_subnet_cidr_block)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}