# # EIP
# resource "aws_eip" "nginxserver-eip" {
#   instance = aws_instance.nginxserver.id
#   vpc      = true
# }

# # #NAT 
# resource "aws_nat_gateway" "nginx-natgw" {
#   allocation_id = aws_eip.nginxserver-eip.id
#   subnet_id     = data.aws_subnet.public-subnet-2.id

#   tags = merge(local.common_tags,
#     { Name = "nategw"
#   Application = "public" })

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [data.aws_internet_gateway.int-gw]
# }