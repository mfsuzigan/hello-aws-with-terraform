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
  request_validator_id = "${aws_api_gateway_request_validator.payment-notification.id}"
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
  resource_id = "${aws_api_gateway_resource.notification.id}"
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  credentials = "${aws_iam_role.trust-role.arn}"
  uri = "arn:aws:apigateway:${var.region}:sns:action/Publish"
  integration_http_method = "POST"
  type = "AWS"

  request_parameters = {
    "integration.request.querystring.TopicArn" = "'${aws_sns_topic.payment-notification-topic.arn}'"
    "integration.request.querystring.Message" = "method.request.body"
  }
}

resource "aws_api_gateway_deployment" "payment-notification"{
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  stage_name = "v1"
}

resource "aws_api_gateway_request_validator" "payment-notification" {
  name = "payment-notification-validator"
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"
  validate_request_body = true
}

resource "aws_api_gateway_model" "payment-notification" {
  content_type = "application/json"
  name = "payment-notification-model"
  rest_api_id = "${aws_api_gateway_rest_api.payment-notification.id}"

  schema = <<EOF
  {
  "type": "object",
  "required": [
  "reference",
  "type",
  "body"
  ],
  "properties": {
  "reference": {
  "type": "string",
  "pattern": "^(.*)$"
  },
  "type": {
  "type": "string",
  "pattern": "^(.*)$"
  },
  "body": {
  "type": "string",
  "pattern": "^(.*)$"
  }
  }
  }
  EOF
}