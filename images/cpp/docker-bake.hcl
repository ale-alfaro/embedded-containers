variable "LLVM_VERSION" {
  default = "20"
}
variable "GCC_VERSION" {
  default = "14"
}
group "default" {
  targets = ["base", "base-dev"]
  }

target "base" {
  dockerfile = "Dockerfile.base"
  context = "."
  args = {
    "GCC_VER": "${GCC_VERSION}",
    "LLVM_VER": "${LLVM_VERSION}"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}

target "base-dev" {

  dockerfile = "Dockerfile.dev"
  contexts = {
    base = "target:base"
  }
  args = {
    "USE_CLANG": "true",
    "LLVM_VER": "${LLVM_VERSION}"
  }

  tags = ["ghcr.io/ale-alfaro/cpp:latest"]
  platforms = ["linux/amd64", "linux/arm64"]
}