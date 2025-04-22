import boto3

def handler(event, context):
    ec2 = boto3.client('ec2')
    ec2.start_instances(InstanceIds=['<replace-with-server1-id>'])
    return "Server 1 started"
