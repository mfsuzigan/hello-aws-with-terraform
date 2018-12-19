provider "aws" {
  region = "${var.region}"
}

variable region {
  default = "us-west-2"
}

### SNS ###
resource "aws_sns_topic" "payment-notification-topic" {
  name = "payment-notification-topic"
}

resource "aws_sns_topic_subscription" "dummy-boleto" {
  endpoint = "arn:aws:sqs:us-west-2:720044753173:test-queue-1"
  protocol = "sqs"
  topic_arn = "${aws_sns_topic.payment-notification-topic.arn}"
  filter_policy = "${data.local_file.boleto-payment-filter-policy.content}"
}

resource "aws_sns_topic_subscription" "dummy-debit-online" {
  endpoint = "arn:aws:sqs:us-west-2:720044753173:test-queue-2"
  protocol = "sqs"
  topic_arn = "${aws_sns_topic.payment-notification-topic.arn}"
  filter_policy = "${data.local_file.debit-online-payment-filter-policy.content}"
}

resource "aws_sns_topic_policy" "payment-notification-policy" {
  arn = "${aws_sns_topic.payment-notification-topic.arn}"
  policy = "${data.aws_iam_policy_document.sns-topic-policy.json}"
}

data "aws_iam_policy_document" "sns-topic-policy" {
  statement {
    actions = [
      "SNS:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.payment-notification-topic.arn}"
    ]
  }
}

data "aws_iam_policy_document" "trust-policy"{
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_iam_role" "trust-role" {
  name = "trust-role"
  assume_role_policy = "${data.aws_iam_policy_document.trust-policy.json}"
}