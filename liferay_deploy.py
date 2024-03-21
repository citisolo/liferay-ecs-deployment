import os
import boto3
import urllib.parse

def lambda_handler(event, context):
    # Initialize boto3 client
    s3_client = boto3.client('s3')

    # Get bucket name and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    # The target EFS path (Ensure the path exists or adapt the code to create it)
    efs_target_path = '/mnt/liferay_deploy'

    # The full path for the file on EFS (adjust as needed)
    file_path_on_efs = os.path.join(efs_target_path, os.path.basename(object_key))

    # Download the file from S3 and save it to the EFS path
    with open(file_path_on_efs, 'wb') as f:
        s3_client.download_fileobj(bucket_name, object_key, f)

    print(f"File {object_key} from bucket {bucket_name} has been copied to {file_path_on_efs}")

    return {
        'statusCode': 200,
        'body': f"Successfully processed {object_key} from {bucket_name}."
    }
