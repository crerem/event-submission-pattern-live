#importing packages
import json
import boto3
import os
#function definition
def lambda_handler(event,context):

	dynamodb = boto3.resource('dynamodb')
	#table name
	table = dynamodb.Table(os.environ['TABLE_NAME'])
	#inserting values into table
	
	if isinstance(event, str):
	    event = json.loads(event)

	my_dictionary = {}
	for key, value in event['body'].items():
	    my_dictionary[key]=value
	    
	    
	response = table.put_item(
	Item=my_dictionary
	)
	return response
