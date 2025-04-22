![Screenshot 2025-02-27 205745](https://github.com/user-attachments/assets/c4799cc3-27bf-41a8-b5af-28179573adf4)



# automate-Ec2-lambda-terraform-cloudwatch
# AWS Auto-Restart Server Solution

This project sets up an automated system to restart EC2 instances in AWS using Lambda functions, CloudWatch rules, and IAM roles, all provisioned through AWS CloudFormation.

## Features
- **Auto-Restart EC2 Instances:** Lambda function triggered by CloudWatch checks instance health.
- **Infrastructure as Code:** Deploy complete architecture via CloudFormation.
- **Security:** IAM roles with least-privilege access.
- **Monitoring:** CloudWatch rules track instance states and trigger actions.

## Architecture
1. **CloudFormation Stack:** Creates EC2 instances, Lambda, IAM roles, and CloudWatch rules.
2. **Lambda Function:** Python script to restart unhealthy EC2 instances.
3. **CloudWatch Rule:** Monitors EC2 instance health and invokes Lambda.
4. **IAM Role:** Grants Lambda permission to manage EC2 instances.

## CloudFormation Template
The CloudFormation template provisions all necessary resources:
```yaml
Resources:
  MyEC2Instance:
    Type: 'AWS::EC2::Instance'
    Properties:
      ImageId: ami-0abcdef1234567890
      InstanceType: t2.micro

  MyLambdaFunction:
    Type: 'AWS::Lambda::Function'
    Properties:
      Handler: index.handler
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        ZipFile: |
          import boto3
          def handler(event, context):
            ec2 = boto3.client('ec2')
            instance_id = event['detail']['instance-id']
            ec2.reboot_instances(InstanceIds=[instance_id])
      Runtime: python3.9

  LambdaExecutionRole:
    Type: 'AWS::IAM::Role'
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: 'sts:AssumeRole'
      Policies:
        - PolicyName: LambdaEC2Policy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - 'ec2:RebootInstances'
                Resource: '*'

  EC2RestartRule:
    Type: 'AWS::Events::Rule'
    Properties:
      EventPattern:
        source:
          - 'aws.ec2'
        detail-type:
          - 'EC2 Instance State-change Notification'
        detail:
          state:
            - 'stopped'
      Targets:
        - Arn: !GetAtt MyLambdaFunction.Arn
          Id: 'TargetFunction'
```

## Deployment
1. **Create the Stack:**
   ```sh
   aws cloudformation create-stack --stack-name AutoRestartStack --template-body file://template.yaml
   ```
2. **Update the Stack:**
   ```sh
   aws cloudformation update-stack --stack-name AutoRestartStack --template-body file://template.yaml
   ```

## How It Works
1. **Instance Stops:** CloudWatch detects stopped EC2 instance.
2. **Trigger Lambda:** CloudWatch invokes the Lambda function.
3. **Restart EC2:** Lambda calls the EC2 API to reboot the instance.

## Conclusion
This solution ensures high availability by automatically restarting failed instances, reducing downtime, and minimizing manual intervention.

Want any adjustments or enhancements? Let me know! 🚀

