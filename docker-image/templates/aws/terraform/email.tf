resource "aws_iam_user" "smtp" {
    provider = "aws.ses_region"
    name = "mailer"
}

resource "aws_iam_user_policy" "smtp_send" {
  name = "test"
  user = "${aws_iam_user.smtp.name}"

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "smtp" {
  user = "${aws_iam_user.smtp.name}"
}

resource "aws_ses_domain_identity" "smtp" {
  provider = "aws.ses_region"
  domain = "${var.domain}"
}

resource "aws_ses_domain_dkim" "smtp" {
  provider = "aws.ses_region"
  domain = "${aws_ses_domain_identity.smtp.domain}"
}

resource "aws_ses_domain_identity_verification" "smtp" {
  provider = "aws.ses_region"
  domain = "${aws_ses_domain_identity.smtp.id}"
  depends_on = ["aws_route53_record.email"]
}
