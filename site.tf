terraform {}

provider "aws" {}

resource "aws_vpc" "daniele-data" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "daniele-igw" {
  vpc_id = "${aws_vpc.daniele-data.id}"
}

resource "aws_eip" "daniele-static_egress" {
  vpc = true
}

resource "aws_subnet" "daniele-public" {
  vpc_id     = "${aws_vpc.daniele-data.id}"
  cidr_block = "10.0.10.0/24"
}

resource "aws_route_table" "daniele-public" {
  vpc_id = "${aws_vpc.daniele-data.id}"
}

resource "aws_route" "daniele-public_igw" {
  route_table_id         = "${aws_route_table.daniele-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.daniele-igw.id}"
}

resource "aws_route_table_association" "daniele-public" {
  subnet_id      = "${aws_subnet.daniele-public.id}"
  route_table_id = "${aws_route_table.daniele-public.id}"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.daniele-static_egress.id}"
  subnet_id     = "${aws_subnet.daniele-public.id}"
}

resource "aws_subnet" "daniele-private" {
  vpc_id     = "${aws_vpc.daniele-data.id}"
  cidr_block = "10.0.20.0/24"
}

resource "aws_route_table" "daniele-private" {
  vpc_id = "${aws_vpc.daniele-data.id}"
}

resource "aws_route" "daniele-private_nat" {
  route_table_id         = "${aws_route_table.daniele-private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "daniele-private" {
  subnet_id      = "${aws_subnet.daniele-private.id}"
  route_table_id = "${aws_route_table.daniele-private.id}"
}
