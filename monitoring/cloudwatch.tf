resource "aws_cloudwatch_metric_alarm" "high_cpu" {
    alarm_name = "highCPUutilization"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUutilization"
    namespace = "AWS/EC2"
    period = 300
    statistic = "Average"
    threshold = 80
    alarm_description = "CPU utilization is more than 80%"
    dimensions = {
      instanceId=""
    }
    alarm_actions = [aws_sns_topic.alerts.arn]  
}

resource "aws_sns_topic" "alerts" {
    name="infra-alerts"  
}