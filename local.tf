locals {
  common_tags={
    Project= var.Project
    Environment =var.Environment
    Terraform = true
  }
}

locals {
  final_vpc_tags =merge(
    local.common_tags,
    {
        Name = "${var.Project}-${var.Environment}"
        },
    var.vpc_tags
    
  )
}