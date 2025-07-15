variable "LLVM_VERSION" {
  default = "20"
}
variable "GCC_VERSION" {
  default = "14"
}
variable "NCS_VERSION" {
  default = "3.0.0"
}
variable "ZSDK_VERSION" {
  default = "0.17.2"
}

group "default" {
  targets = ["ncs"]
}

target "cpp-base" {
  dockerfile = "./images/cpp/Dockerfile.base"
  args = {
    "GCC_VER": "${GCC_VERSION}",
    "LLVM_VER": "${LLVM_VERSION}"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}

target "cpp-base-dev" {
  dockerfile = "./images/cpp/Dockerfile.dev"
  contexts = {
    base = "target:cpp-base"
  }
  args = {
    "USE_CLANG": "true",
    "LLVM_VER": "${LLVM_VERSION}"
  }
  tags = ["ghcr.io/ale-alfaro/base-dev:latest"]
  platforms = ["linux/amd64", "linux/arm64"]
}

target "common_metadata" {

  tags = [
    "ghcr.io/ale-alfaro/ncs:${NCS_VERSION}"
  ]
  labels = {
      "org.opencontainers.image.source" = "https://github.com/ale-alfaro/embedded-containers",
      "org.opencontainers.image.description" = "NCS development environment for linux"
  }
  annotations = ["index,manifest:org.opencontainers.image.authors=ale-alfaro", 
                "index,manifest:org.opencontainers.image.url=https://github.com/ale-alfaro/embedded-containers"]
}

target "ncs" {
  inherits = [ "common_metadata" ]
  dockerfile = "./images/ncs/Dockerfile.base"
  contexts = {
      "ubuntu-cpp" = "docker-image://ghcr.io/ale-alfaro/base-dev:latest"
  }
  args = {
    "NCS_VERSION" = "${NCS_VERSION}"
    "ZSDK_VERSION" = "${ZSDK_VERSION}"
    "WORKSPACE_FOLDER" = "/workspace"
  }

  platforms = ["linux/amd64"]
}
