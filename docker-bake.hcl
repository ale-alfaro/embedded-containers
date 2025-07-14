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
  context = "./images/cpp"
  args = {
    "GCC_VER": "${GCC_VERSION}",
    "LLVM_VER": "${LLVM_VERSION}"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}

target "cpp-base-dev" {
  dockerfile = "./images/cpp/Dockerfile.dev"
  context = "./images/cpp"
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

target "ncs-base" {
  dockerfile = "./images/ncs/Dockerfile.base"
  context = "./images/ncs"
  contexts = {
    "ubuntu-cpp" = "target:cpp-base-dev"
  }
  args = {
    "NCS_VERSION": "${NCS_VERSION}",
    "ZSDK_VERSION": "${ZSDK_VERSION}"
  }
}

target "ncs" {
  name = "ncs-${platform}"
  dockerfile = "./images/ncs/Dockerfile.${platform}"
  context = "./images/ncs"
  contexts = {
    "base-ncs" = "target:ncs-base"
  }
  matrix = {
    "platform" = ["amd64", "arm64"]
  }
  platforms = ["linux/${platform}"]
  tags = ["ghcr.io/ale-alfaro/ncs:${NCS_VERSION}"]
}