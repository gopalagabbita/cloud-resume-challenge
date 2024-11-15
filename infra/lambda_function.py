import boto3
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('VisitorCount')

def lambda_handler(event, context):
    response = table.update_item(
        Key={'id': 'count'},
        UpdateExpression="ADD visitor_count :inc",
        ExpressionAttributeValues={':inc': 1},
        ReturnValues="UPDATED_NEW"
    )

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps({'visitor_count': int(response['Attributes']['visitor_count'])})
    }
