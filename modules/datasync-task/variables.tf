variable "datasync_tasks" {
  type = list(object({
    destination_location_arn = string
    source_location_arn      = string
    cloudwatch_log_group_arn = optional(string)
    excludes                 = optional(object({ filter_type = string, value = string }))
    includes                 = optional(object({ filter_type = string, value = string }))
    name                     = optional(string)
    options                  = optional(map(string))
    schedule_expression      = optional(string)
    tags                     = optional(map(string))
    task_mode                = optional(string)
    region                   = optional(string)
  }))
  default     = []
  description = "A list of task configurations"

  validation {
    condition = alltrue([
      for task in var.datasync_tasks :
      !(try(task.task_mode, null) == "ENHANCED" && try(task.options.bytes_per_second, null) != null)
    ])
    error_message = "Enhanced mode does not support bandwidth limits (bytes_per_second). Remove bytes_per_second or use BASIC mode."
  }

  validation {
    condition = alltrue([
      for task in var.datasync_tasks :
      !(try(task.task_mode, null) == "ENHANCED" && try(task.options.verify_mode, null) == "POINT_IN_TIME_CONSISTENT")
    ])
    error_message = "Enhanced mode does not support verify_mode = 'POINT_IN_TIME_CONSISTENT'. Use 'ONLY_FILES_TRANSFERRED' or 'NONE' instead."
  }
}
