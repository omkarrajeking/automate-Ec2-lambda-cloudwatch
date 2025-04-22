import boto3

def handler(event, context):
    ec2 = boto3.client('ec2')
    ec2.start_instances(InstanceIds=['<replace-with-server2-id>'])
    return "Server 2 started"
