resource "aws_iam_role" "lambdaRole" {
  name = "lambdaRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow"
        "Action" : [
          "sts:AssumeRole"
        ]
        "Principal" : {
          "Service" : [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambdaPolicy" {
  name = "lambdaPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource" : "arn:aws:logs:*:*:*"
      },
      {
            "Effect": "Allow",
            "Action": [
                "ses:*"
            ],
            "Resource": "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambdaRolePolicyAttachment" {
  policy_arn = aws_iam_policy.lambdaPolicy.arn
  roles      = [aws_iam_role.lambdaRole.name]
  name       = "lambdaRolePolicyAttachment"
}

data "archive_file" "lambdaFile" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  role             = aws_iam_role.lambdaRole.arn
  filename         = data.archive_file.lambdaFile.output_path
  source_code_hash = data.archive_file.lambdaFile.output_base64sha256
  function_name    = "lambda"
  timeout          = 60
  runtime          = "python3.9"
  handler          = "lambda.lambda_handler"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.basic-dynamodb-table.name
      SENDER_EMAIL = aws_ses_email_identity.approved_email.email
    }
  }
}

resource "aws_lambda_permission" "lambdaPermission" {
  statement_id  = "lambdaPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.ContactFormApi.execution_arn}/*"
}