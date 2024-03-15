import boto3
import json
import csv
from io import StringIO
import tarfile
from IPython.display import JSON
from botocore.exceptions import ClientError
import pandas as pd
import time
from datetime import datetime, timezone
import seaborn as sn
import matplotlib.pyplot as plt

TEMP_FILE = '/tmp/cmresult.csv'

s3 = boto3.resource('s3')
client = boto3.client('comprehend')
    
# This gets triggered from when CSV obj file is add to S3 bucket.
# It extracts the value for the key "PROCEDURE" and analyzes through
# comprehend to extract various pii enties. Then it writes these
# results to S3 as CSV file

def lambda_handler(event, context):
    comprehend = boto3.client('comprehend')

    comprehend_train_file = TEMP_FILE

    # train_object_name = 'train/' + comprehend_train_file

    print('******* Event body *******', event['body'])

    s3uri = 's3://aws_s3_bucket.resultbucket.bucket'
    output_s3uri = 's3://aws_s3_bucket.resultbucket1.bucket'
    document_classifier_name = 'adr-clssifier-prod10'
    document_classifier_arn = ''
    response = None

    try:
        create_response = comprehend.create_document_classifier(
            DocumentClassifierName=document_classifier_name,
            DataAccessRoleArn='aws_iam_role.comprehend-role.arn',
            InputDataConfig={
                'DataFormat': 'COMPREHEND_CSV',
                'S3Uri': s3uri
            },
            OutputDataConfig={
                'S3Uri': output_s3uri
            },
            LanguageCode='en',
            mode='MULTI_LABEL'
        )

        document_classifier_arn = response['DocumentClassifierArn']
    except ClientError as error:
        if error.response['Error']['Code'] == 'ResourceInUseException':
            print('A classifier with the name "{0}" already exists. Hence not creating it.'.format(document_classifier_name))
            document_classifier_arn = 'arn:aws:comprehend:{0}:{1}:document-classifier/{2}'.format(datetime, document_classifier_name)
        
    print('Document Classifier ARN: ' + document_classifier_arn)
    print("Create response: %s/n", create_response)

    
    return {
        'statusCode': 200,
        'body': json.dumps('Success!')
    }
