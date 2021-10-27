# Dit gaan we nabouwen
#
# https://d2908q01vomqb2.cloudfront.net/1b6453892473a467d07372d45eb05abc2031647a/2018/01/26/Slide5.png
# TODO: maak variabel en gebruik meerdere availability_zones
#

# van buiten naar binnen

# naamconeventie? repo-branch-resource? dit nog toevoegen in naamgeving, en standaard labelset

# ik denk dat hier wel modules voor zijn

# begin met vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# voeg internet gateway toe aan vpc, zodat het aan het internet hangt
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# hier komen de container endpoints in
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  #TODO: availability_zone
}

# hier komen de loadbalancers in
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  #TODO: availability_zone
}

# routeer het verkeer naar de internet gateway in de public subnet

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# het verkeer uit de private network moet wel naar buiten kunnen

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.main]
}

# Waarom is dit nodig?
resource "aws_eip" "nat" {
  vpc = true
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}