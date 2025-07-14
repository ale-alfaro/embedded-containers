variable "NCS_VERSION" {
  default = "3.0.0"
}

variable "NCS_VERSION" {
  default = "3.0.0"
}

variable "ZSDK_VERSION" {
  default = "0.17.2"
}

variable "TAG" {
  default = "${NCS_VERSION}"
}

variable "WORKSPACE_FOLDER" {
  default = "/workspace"
}
group "default" {
  targets = [
    "ncs-arm64",
    "ncs-amd64"
  ]
}

target "common-variables" {
  args = {
    "NCS_VERSION" = "${NCS_VERSION}"
    "ZSDK_VERSION" = "${ZSDK_VERSION}"
    "WORKSPACE_FOLDER" = "${WORKSPACE_FOLDER}"
  }
}

target "base-ncs" {
  inherits = [ "common-variables" ]
  contexts = {
      "ubuntu-cpp" = "docker-image://ghcr.io/ale-alfaro/base-dev:latest"
  }
  dockerfile = "Dockerfile.base"


}

target "common_metadata" {

  tags = [
    "ghcr.io/ale-alfaro/ncs:${TAG}"
  ]
  labels = {
      "org.opencontainers.image.title" = "ncs",
      "org.opencontainers.image.description" = "NCS development environment for linux",
      "org.opencontainers.image.version" = "${NCS_VERSION}",
  }
}

target "ncs" {
  name = "ncs-${platform}"
  dockerfile = "Dockerfile.${platform}"
  inherits = [ "common_metadata" , "common-variables" ]
  contexts = {
      "base-ncs" = "target:base-ncs"
  }
  matrix = {
    "platform" = [ "amd64", "arm64" ]
  }
  platforms = ["linux/${platform}"]
}
