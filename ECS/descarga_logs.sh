TASK_ARN="arn:aws:ecs:us-east-1:512083376485:task/aws-architect-battle-arena-cluster/a1a9ab99c6254db1ba4e98193c4f669b"
CLUSTER="aws-architect-battle-arena-cluster"

# Obtener log group y stream
LOG_GROUP=$(aws ecs describe-tasks \
  --cluster "$CLUSTER" \
  --tasks "$TASK_ARN" \
  --query "tasks[0].containers[0].logConfiguration.options.\"awslogs-group\"" \
  --output text)

LOG_STREAM=$(aws ecs describe-tasks \
  --cluster "$CLUSTER" \
  --tasks "$TASK_ARN" \
  --query "tasks[0].containers[0].logStreamName" \
  --output text)

# Rango de tiempo
START_TIME=$(date -u -d "$(date +%Y-%m-%d) 00:00:00" +%s000)
END_TIME=$(date -u +%s000)

# Descargar logs
aws logs get-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$LOG_STREAM" \
  --start-time $START_TIME \
  --end-time $END_TIME \
  --limit 10000 \
  --output text > logs_ecs_today.txt

