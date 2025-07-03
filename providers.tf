
/*terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.5.0"
    }
  }
}
*/

terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.26, < 7"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.26, < 7"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-lb-internal/v7.0.0"
  }

  provider_meta "google-beta" {
    module_name = "blueprints/terraform/terraform-google-lb-internal/v7.0.0"
  }
}
provider "google" {

  credentials = file("./credentials.json")

}
provider "google-beta" {
  credentials = file("./credentials.json")
}
