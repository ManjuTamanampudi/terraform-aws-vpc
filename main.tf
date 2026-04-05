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
    count = length(var.subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block[count.index]
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
    count = length(var.subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block[count.index]
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
    count = length(var.subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block[count.index]
  availability_zone= local.azs_info[count.index]

  tags= merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}-db-${local.azs_info[count.index]}",
        },
    var.db_subnet_tags    
  )
}