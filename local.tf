locals {
  common_tags={
    Project= var.Project
    Environment =var.Environment
    Terraform = true
  }

  final_vpc_tags =merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}"
        },
    var.vpc_tags
    
  )

    final_igw_tags= merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}"
        },
    var.igw_tags
    
  )

 
  azs_info= slice(data.aws_availability_zones.available.names, 0,2)
}
