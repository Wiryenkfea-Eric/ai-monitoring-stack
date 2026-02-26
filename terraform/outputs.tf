output "monitoring_public_ip" {
  description = "Public IP of the monitoring server (Prometheus + Grafana)"
  value       = aws_instance.monitoring.public_ip
}
 
output "splunk_public_ip" {
  description = "Public IP of the Splunk server"
  value       = aws_instance.splunk.public_ip
}
 
output "app_public_ip" {
  description = "Public IP of the Flask application server"
  value       = aws_instance.app.public_ip
}
 
output "app_private_ip" {
  description = "Private IP of app server (used in Prometheus config)"
  value       = aws_instance.app.private_ip
}
