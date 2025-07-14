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

target "common-variables" {
  args = {
    "NCS_VERSION" = "${NCS_VERSION}"
    "ZSDK_VERSION" = "${ZSDK_VERSION}"
    "WORKSPACE_FOLDER" = "/workspace"
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
    "ghcr.io/ale-alfaro/ncs:${NCS_VERSION}"
  ]
  labels = {
      "org.opencontainers.image.source" = "https://github.com/ale-alfaro/embedded-containers",
      "org.opencontainers.image.description" = "NCS development environment for linux"
  }
  annotations = ["index,manifest:org.opencontainers.image.authors=ale-alfaro", 
                "index,manifest:org.opencontainers.image.url=https://github.com/ale-alfaro/embedded-containers"]
}

target "ncs-base" {
  dockerfile = "./images/ncs/Dockerfile.base"
  contexts = {
    "ubuntu-cpp" = "target:cpp-base-dev"
  }
  inherits = [ "common-variables" ]
}

target "ncs" {
  inherits = [ "common-variables" , "common_metadata" ]
  name = "ncs-${platform}"
  dockerfile = "./images/ncs/Dockerfile.${platform}"
  contexts = {
    "base-ncs" = "target:ncs-base"
  }

  matrix = {
    "platform" = ["amd64", "arm64"]
  }
  platforms = ["linux/${platform}"]
}