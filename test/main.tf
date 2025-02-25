module "stack" {
  source = "git@github.com:faelvinicius/terraform-aws-alerts.git"
  stack = {
    alert = {
      endpoint = "rafael.julio@ops.team"
    }
  }
}