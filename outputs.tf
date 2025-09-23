output "instance_ami" {
  value = aws_instance.web_blog.ami
}

output "instance_arn" {
  value = aws_instance.web_blog.arn
}
