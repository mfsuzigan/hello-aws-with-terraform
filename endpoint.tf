### SNS ###

## Api Gateway ##
# api gateway rest api
resource "aws_api_gateway_rest_api" "payment-notification-api" {
  name = "payment-notification"
  description = "Payment notification"
}

resource "aws_api_gateway_resource" "payment-notification-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification-api.id}"
  parent_id = "${aws_api_gateway_rest_api.payment-notification-api.root_resource_id}"
  path_part = "notifications"
}

resource "aws_api_gateway_method" "payment-notification-http-method" {
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification-api.id}"
  resource_id = "${aws_api_gateway_resource.payment-notification-resource.id}"
  http_method = "POST"
  authorization = "NONE"

  request_parameters {
    "method.request.querystring.Message" = true
    #"method.request.querystring.TopicArn" = true
  }
}

resource "aws_api_gateway_method_response" "payment-notification-response" {
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification-api.id}"
  http_method = "${aws_api_gateway_method.payment-notification-http-method.http_method}"
  resource_id = "${aws_api_gateway_resource.payment-notification-resource.id}"
  status_code = "200"
}

resource "aws_api_gateway_integration" "payment-notification-integration" {
  http_method = "${aws_api_gateway_method.payment-notification-http-method.http_method}"
  integration_http_method = "POST"
  resource_id = "${aws_api_gateway_resource.payment-notification-resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification-api.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:sns:action/Publish"
  credentials = "${aws_iam_role.trust-role.arn}"

  request_parameters = {
    "integration.request.querystring.TopicArn" = "'${aws_sns_topic.payment-notification-topic.arn}'"
    "integration.request.querystring.Message" = "method.request.querystring.Message"
  }
}

