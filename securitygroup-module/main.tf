resource "aws_security_group" "main" {
  name        = var.sg_name
  description = var.description
  vpc_id      = var.vpcid
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  tags = merge(
    var.sg_tags,
    local.common_tags,
    {
        Name = local.common_name_suffix
    }
  )
}