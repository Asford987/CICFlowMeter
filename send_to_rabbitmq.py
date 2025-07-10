import pika
import sys
import os

queue = os.environ.get("RABBITMQ_QUEUE", "flow-logs")
host = os.environ.get("RABBITMQ_HOST", "rabbitmq")

def publish_message(message):
    connection = pika.BlockingConnection(pika.ConnectionParameters(host=host))
    channel = connection.channel()
    channel.queue_declare(queue=queue, durable=True)
    channel.basic_publish(
        exchange='',
        routing_key=queue,
        body=message.encode('utf-8'),
        properties=pika.BasicProperties(delivery_mode=2)  # make message persistent
    )
    connection.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: send_to_rabbitmq.py <csv-file>")
        sys.exit(1)
    
    with open(sys.argv[1], "r") as f:
        lines = f.readlines()[1:]  # Skip CSV header
        for line in lines:
            publish_message(line.strip())
