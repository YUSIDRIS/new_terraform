resource "aws_launch_configuration" "as_conf" {
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "m4.large"
  spot_price    = "0.001"

  lifecycle {
    create_before_destroy = true
  }
}
