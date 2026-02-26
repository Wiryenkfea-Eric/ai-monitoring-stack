# Look up the latest Amazon Linux 2023 AMI automatically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
 
# ── EC2: Monitoring Server (Prometheus + Grafana) ──
resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.monitoring.id]
 
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
 
  tags = {
    Name    = "${var.project_name}-monitoring"
    Project = var.project_name
    Role    = "monitoring"
  }
}
 
# ── EC2: Splunk Server ───────────────────────────
resource "aws_instance" "splunk" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.medium"   # Splunk needs at least 4GB RAM
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.splunk.id]
 
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
 
  tags = {
    Name    = "${var.project_name}-splunk"
    Project = var.project_name
    Role    = "splunk"
  }
}
 
# ── EC2: Flask App Server ────────────────────────
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.app.id]
 
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
 
  tags = {
    Name    = "${var.project_name}-app"
    Project = var.project_name
    Role    = "app"
  }
}
