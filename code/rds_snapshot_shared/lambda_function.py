import json
import boto3

SNS_TOPIC_ARN = os.getenv("SNS_TOPIC_ARN")

def lambda_handler(event, context):
    sns_client = boto3.client('sns')

    detail = event.get("detail", {})
    snapshot_id = detail.get("requestParameters", {}).get("dBSnapshotIdentifier", "Desconhecido")
    shared_accounts = detail.get("requestParameters", {}).get("valuesToAdd", [])

    # Verifica se o snapshot foi compartilhado com contas externas
    if shared_accounts:
        message = f"""
        🚨 Alerta: Snapshot do RDS Compartilhado 🚨
        - Snapshot: {snapshot_id}
        - Compartilhado com as contas: {", ".join(shared_accounts)}
        """

        # Publicar no SNS
        response = sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message,
            Subject="🚀 Alerta: Snapshot do RDS Compartilhado"
        )

        return {
            "statusCode": 200,
            "body": json.dumps(f"Mensagem enviada ao SNS: {response['MessageId']}")
        }
    
    return {
        "statusCode": 200,
        "body": json.dumps("Nenhuma ação necessária.")
    }
