module "stack" {
  source = "./module"
  stack = {
    alert = {
      endpoint = "rafael.julio@ops.team"
    }
  }
}