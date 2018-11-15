data "aws_route53_zone" "main" {
  name = "${var.domain}"
}

resource "aws_route53_record" "main" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.domain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_eip.edge.*.public_ip}"
  ]
}

resource "aws_route53_record" "wildcard" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "*.${var.domain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_eip.edge.*.public_ip}"
  ]
}

resource "aws_route53_record" "email" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.smtp.verification_token}"]
}

resource "aws_route53_record" "email_dkim" {
  count   = 3
  zone_id = "${data.aws_route53_zone.main.zone_id}"

  name    = "${element(aws_ses_domain_dkim.smtp.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.smtp.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
