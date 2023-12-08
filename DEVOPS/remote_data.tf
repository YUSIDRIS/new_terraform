data "terraform_remote_state" "Network" {
  backend = "s3"
  config = {
    bucket = "idristerraformstate1"
    key    = "Network.statefile"
    region = "us-west-2"
  }
}