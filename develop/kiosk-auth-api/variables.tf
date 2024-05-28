variable "docker_image_tag" {
  description = "docker_image_tag"
}

variable "app_service_name" {
  description = "app_service_name"
}

variable "kiosk_auth_api_db_secret_key" {
  description = "kiosk_auth_api_db_secret_key"
}

variable "kiosk_auth_api_jwt_secret_key" {
  description = "kiosk_auth_api_jwt_secret_key"
}

variable "access_token_lifetime" {
  description = "access_token_lifetime"
}

variable "refresh_token_lifetime" {
  description = "refresh_token_lifetime"
}
