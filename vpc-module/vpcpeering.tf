
resource "aws_vpc_peering_connection" "peering" {

  count = var.peering == "true" ?  1 :  0
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = data.aws_vpc.default.id
  auto_accept   = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${local.common_name_suffix}-peering"
  }
}

##routes for roboshop vpc to default vpc vpcpeering

resource "aws_route" "roboshop_vpc_to_default_vpc" {
  count = var.peering == "true" ? 1 : 0
  route_table_id            = aws_route_table.public_routetable.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}
##routes for defaultvpc to roboshopvpc
resource "aws_route" "default_vpc_to_roboshop_vpc" {
  count = var.peering == "true" ? 1 : 0  
  route_table_id            = data.aws_route_table.default_route_id.id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}