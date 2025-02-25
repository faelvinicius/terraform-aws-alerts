variable "stack" {
  description = "Custom parameters"
  type = map(object({
    protocol               = optional(string, "email")
    endpoint               = optional(string, "")
    endpoint_auto_confirms = optional(bool, false)
    runtime = optional(string, "python3.9")
    type = optional(string, "zip")
    handler = optional(string, "lambda_function.lambda_handler")
    output_path = optional(string, "lambda_function_payload.zip")
    filename = optional(string, "lambda_function_payload.zip")
    target_id = optional(string, "SendToLambda")
  }))
  
}