resource "aws_efs_file_system" "liferay_efs" {
  creation_token = "liferay-efs"

  tags = {
    Name = "liferay-efs"
  }
}

resource "aws_efs_mount_target" "liferay_efs_mt" {
  count           = length(aws_subnet.ecs_subnet.*.id)
  file_system_id  = aws_efs_file_system.liferay_efs.id
  subnet_id       = aws_subnet.ecs_subnet[count.index].id
  security_groups = [aws_security_group.liferay_sg.id]
}

resource "aws_iam_policy" "efs_access_policy" {
  name        = "EFSAccessPolicy"
  description = "Policy granting access to EFS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_efs_access_point" "lambda_ap" {
  file_system_id = aws_efs_file_system.liferay_efs.id

  posix_user {
    gid = 1001
    uid = 1001
  }

  root_directory {
    path = "/" 
    creation_info {
      owner_gid   = 1001
      owner_uid   = 1001
      permissions = "755"
    }
  }
}


