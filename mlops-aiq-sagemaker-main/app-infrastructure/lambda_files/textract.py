import json
import boto3
from urllib.parse import unquote_plus

client = boto3.client('textract')
sqs_client = boto3.client('sqs')


def extractText(response, extract_by="WORD"):
    lineText = []
    for block in response["Blocks"]:
        if block["BlockType"] == extract_by:
            lineText.append(block["Text"])
    return lineText


def lambda_handler(event, context):
    textract = boto3.client("textract")
    if event:
        fileObj = event["Records"][0]
        bucketName = str(fileObj["s3"]["bucket"]["name"])
        fileName = unquote_plus(str(fileObj["s3"]["object"]["key"]))

        print(f"Bucket: {bucketName} ::: Key: {fileName}")

        response = textract.detect_document_text(
            Document={
                "S3Object": {
                    "Bucket": bucketName,
                    "Name": fileName,
                }
            }
        )
        print(json.dumps(response))

        # change WORD by LINE if you want line level extraction
        rawText = extractText(response, extract_by="WORD")
        print(rawText)

        return {
            "statusCode": 200,
            "body": json.dumps("Document processed successfully!"),
        }

    return {"statusCode": 500, "body": json.dumps("There is an issue!")}