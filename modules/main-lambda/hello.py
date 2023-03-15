import json
import boto3
import uuid
import os
from json import dumps
client = boto3.client('stepfunctions')

def lambda_handler(event, context):

	for record in event['Records']:
	    body = record['body']
	 
       
	transactionId = str(uuid.uuid1())
	
	response = client.start_execution(
		stateMachineArn= os.environ['STEP_FUNCTION_ARN'],
		name=transactionId,
		input=body	
	)
