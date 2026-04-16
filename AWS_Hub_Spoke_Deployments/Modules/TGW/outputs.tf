output "tgw_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "tgw_rt_id" {
  value = aws_ec2_transit_gateway_route_table.main.id
}
