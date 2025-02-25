import json
import boto3
import os

SNS_TOPIC_ARN = os.getenv("SNS_TOPIC_ARN")

def lambda_handler(event, context):
    sns_client = boto3.client('sns')

    records = event.get("detail", {})
    event_name = records.get("eventName")
    
    if event_name == "CreateUser":
        user_name = records.get("requestParameters", {}).get("userName", "Desconhecido")
        requester = records.get("userIdentity", {}).get("arn", "Não identificado")
        
        message = f"""
        🚨 Novo Usuário IAM Criado 🚨
        - Usuário: {user_name}
        - Criado por: {requester}
        """

        response = sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message,
            Subject="🚀 Alerta: Novo Usuário IAM Criado"
        )

        return {
            "statusCode": 200,
            "body": json.dumps(f"Mensagem enviada ao SNS: {response['MessageId']}")
        }
    
    return {
        "statusCode": 200,
        "body": json.dumps("Nenhuma ação necessária.")
    }
