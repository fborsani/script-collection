import boto3
from botocore.exceptions import ClientError


SENDER = "NAME <sender@example.com>"
RECIPIENT = "recipient@example.com"
CONFIGURATION_SET = "ConfigSet"
AWS_REGION = "us-west-2"
SUBJECT = "Amazon SES Test (SDK for Python)"
BODY_TEXT = (
            "test"
)
            
CHARSET = "UTF-8"
client = boto3.client('ses',region_name=AWS_REGION)

try:
    response = client.send_email(
        Destination={
            'ToAddresses': [
                RECIPIENT,
            ],
        },
        Message={
            'Body': {
                'Html': {
                    'Charset': CHARSET,
                    'Data': BODY_HTML,
                },
                'Text': {
                    'Charset': CHARSET,
                    'Data': BODY_TEXT,
                },
            },
            'Subject': {
                'Charset': CHARSET,
                'Data': SUBJECT,
            },
        },
        Source=SENDER,
        ConfigurationSetName=CONFIGURATION_SET,
    )
except ClientError as e:
    print(e.response['Error']['Message'])
else:
    print("Email sent! Message ID:"),
    print(response['MessageId'])