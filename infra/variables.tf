
variable region {
    description = "The AWS region to deploy resources"
    default     = "eu-west-1"
}

variable liferay_image {
    description = "The Liferay Docker image to deploy"
    default     = "liferay/dxp:2024.q1.1"
}

variable liferay_deploy_dir {
    description = "The directory in the Liferay container to deploy files"
    default     = "efs"
}