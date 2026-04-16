resource "aws_ec2_transit_gateway" "this" {
  description = "main-tgw"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  lifecycle {
    prevent_destroy = false 
  }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}
