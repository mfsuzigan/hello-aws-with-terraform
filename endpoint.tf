### SNS ###

## Api Gateway ##
# api gateway rest api
resource "aws_api_gateway_rest_api" "payment-notification" {
  name = "payment-notification"
  description = "Payment notification"
}

resource "aws_api_gateway_resource" "notification" {
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  parent_id = "${aws_api_gateway_rest_api.payment-notification.root_resource_id}"
  path_part = "notifications"
}

resource "aws_api_gateway_method" "notification" {
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  resource_id = "${aws_api_gateway_resource.notification.id}"
  http_method = "POST"
  authorization = "NONE"

  request_parameters {
    "method.request.querystring.Message" = true
    #"method.request.querystring.TopicArn" = true
  }
}

resource "aws_api_gateway_method_response" "ok" {
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  http_method = "${aws_api_gateway_method.notification.http_method}"
  resource_id = "${aws_api_gateway_resource.notification.id}"
  status_code = "200"

  response_models {
      "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "ok" {
  http_method = "${aws_api_gateway_method.notification.http_method}"
  resource_id = "${aws_api_gateway_resource.notification.id}"
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  status_code = "${aws_api_gateway_method_response.ok.status_code}"
}


resource "aws_api_gateway_integration" "notification-topic" {
  http_method = "${aws_api_gateway_method.notification.http_method}"
  integration_http_method = "POST"
  resource_id = "${aws_api_gateway_resource.notification.id}"
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:sns:action/Publish"
  credentials = "${aws_iam_role.trust-role.arn}"

  request_parameters = {
    "integration.request.querystring.TopicArn" = "'${aws_sns_topic.payment-notification-topic.arn}'"
    "integration.request.querystring.Message" = "method.request.querystring.Message"
  }
}

