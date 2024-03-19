
variable region {
    description = "The AWS region to deploy resources"
    default     = "eu-west-1"
}

variable liferay_image {
    description = "The Liferay Docker image to deploy"
    default     = "liferay/portal:7.4.3.112-ga112"
}