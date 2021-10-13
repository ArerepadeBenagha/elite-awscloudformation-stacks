
#####------ Certificate -----------####
resource "aws_acm_certificate" "nginxcert" {
  domain_name       = "*.elietesolutionsit.de"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags,
    { Name = "registration-app.elietesolutionsit.de"
  Cert = "nginxcert" })
}

###-------- SSL Cert ------#####
resource "aws_lb_listener" "nginxapp_lblist2" {
  load_balancer_arn = aws_lb.nginxlb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-southeast-1:901445516958:certificate/ee953706-3e45-48cd-8121-689d8ad7bd11"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginxapp_tglb.arn
  }
}

###------- Cert Validation -------###
data "aws_route53_zone" "main-zone" {
  name         = "elietesolutionsit.de"
  private_zone = false
}

resource "aws_route53_record" "nginxzone_record" {
  for_each = {
    for dvo in aws_acm_certificate.nginxcert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main-zone.zone_id
}

resource "aws_acm_certificate_validation" "nginxcert" {
  certificate_arn         = aws_acm_certificate.nginxcert.arn
  validation_record_fqdns = [for record in aws_route53_record.nginxzone_record : record.fqdn]
}

##------- ALB Alias record ----------##
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main-zone.zone_id
  name    = "registration-app.elietesolutionsit.de"
  type    = "A"

  alias {
    name                   = aws_lb.nginxlb.dns_name
    zone_id                = aws_lb.nginxlb.zone_id
    evaluate_target_health = true
  }
}