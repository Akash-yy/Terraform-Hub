resource "aws_instance" "this" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  subnet_id = var.subnet_id

  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = var.name
  }
}
