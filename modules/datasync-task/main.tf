resource "aws_datasync_task" "datasync_tasks" {
  for_each = {
    for index, task in var.datasync_tasks :
    index => task # Assign key => value
  }
  destination_location_arn = each.value.destination_location_arn
  source_location_arn      = each.value.source_location_arn
  cloudwatch_log_group_arn = try(each.value.cloudwatch_log_group_arn, null)
  # Enhanced mode is only supported for S3-to-S3, Azure Blob-to-S3, and other cloud-to-S3 transfers
  # Enhanced mode requires iam:CreateServiceLinkedRole permission
  # Once set, task_mode cannot be changed after task creation
  task_mode                = try(each.value.task_mode, null)

  excludes {
    filter_type = try(each.value.excludes.filter_type, null)
    value       = try(each.value.excludes.value, null)
  }
  includes {
    filter_type = try(each.value.includes.filter_type, null)
    value       = try(each.value.includes.value, null)

  }
  name = try(each.value.name, null)
  options {
    atime                          = try(each.value.options.atime, null)
    # WARNING: Enhanced mode does not support bandwidth limits (bytes_per_second)
    # Setting bytes_per_second with enhanced mode may cause task creation to fail
    bytes_per_second               = try(each.value.options.bytes_per_second, null)
    gid                            = try(each.value.options.gid, null)
    log_level                      = try(each.value.options.log_level, null)
    mtime                          = try(each.value.options.mtime, null)
    # WARNING: Enhanced mode with object_tags = "PRESERVE" will fail immediately 
    # if locations don't support object tagging (S3-to-S3 supports tagging)
    object_tags                    = try(each.value.options.object_tags, null)
    overwrite_mode                 = try(each.value.options.overwrite_mode, null)
    posix_permissions              = try(each.value.options.posix_permissions, null)
    preserve_deleted_files         = try(each.value.options.preserve_deleted_files, null)
    preserve_devices               = try(each.value.options.preserve_devices, null)
    security_descriptor_copy_flags = try(each.value.options.security_descriptor_copy_flags, null)
    task_queueing                  = try(each.value.options.task_queueing, null)
    transfer_mode                  = try(each.value.options.transfer_mode, null)
    uid                            = try(each.value.options.uid, null)
    # Enhanced mode only verifies transferred data, not all data (recommended: ONLY_FILES_TRANSFERRED)
    verify_mode                    = try(each.value.options.verify_mode, null)

  }

  dynamic "schedule" {
    for_each = each.value.schedule_expression != null ? toset([each.value.schedule_expression]) : toset([])
    content {
      schedule_expression = each.value.schedule_expression
    }
  }

  tags = try(each.value.tags, null)
}
