provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
  alias   = "usw2"
  version = "~> 1.46"
}
