#######################################Internet Facing Application Load Balancer##########################
resource "aws_security_group" "public_alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from Internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the ALB
resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false # Public ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
}

# Create the Target Group (for NGINX reverse proxy instances)
resource "aws_lb_target_group" "public_alb_tg" {
  name        = "public-alb-tg"
  port        = var.target_group_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance" # Target is EC2 instance(s) running NGINX

  health_check {
    path                = "/"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# # ALB Listener (HTTP 80)
resource "aws_lb_listener" "alp_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_alb_tg.arn
  }
}
resource "aws_lb_target_group_attachment" "nginx" {
  count            = 2
  target_group_arn = aws_lb_target_group.public_alb_tg.arn
  target_id        = var.public_instance_ids[count.index]
  port             = 80
}
#######################################Internal Application Load Balancer##########################
resource "aws_security_group" "internal_alb_sg" {
  name        = "internal-alb-sg"
  description = "Allow HTTP from reverse proxy/NAT"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.rev_proxy_sg_id] # allow traffic only from reverse proxy
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "private_alb" {
  name               = "private-alb"
  internal           = true # Internal ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = var.private_subnets

  enable_deletion_protection = false
}

# Target group for private Flask app instances
resource "aws_lb_target_group" "internal_alb_tg" {
  name        = "internal-alb-tg"
  port        = var.target_group_port # Host port (mapped to container port 5000)
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# ALB Listener (HTTP 80)
resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.private_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_alb_tg.arn
  }
}
resource "aws_lb_target_group_attachment" "flask" {
  count            = 2
  target_group_arn = aws_lb_target_group.internal_alb_tg.arn
  target_id        = var.private_instance_ids[count.index]
  port             = 80 # Host port (container maps 5000 -> 80)
}
