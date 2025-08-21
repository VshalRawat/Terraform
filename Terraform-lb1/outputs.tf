 output "instance_id" {
   description = "ID of the vishal EC2 instance"
   value = aws_instance.my_ec2.id
 }

 output "bucket_arn" {
   description = "get you the bucket ARN"
   value = aws_s3_bucket.my_bucket.arn
 }

 output "s3_bucket_name" {
   description = "the name of vishal s3 bucket"
   value = aws_s3_bucket.my_bucket.bucket
 }
