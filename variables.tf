
variable region {
    description = "The AWS region to deploy resources"
    default     = "eu-west-1"
}

variable liferay_image {
    description = "The Liferay Docker image to deploy"
    default     = "liferay/dxp:7.4.13-u48-d5.0.2-20221027081838"
}

variable liferay_deploy_dir {
    description = "The directory in the Liferay container to deploy files"
    default     = "liferay"
}