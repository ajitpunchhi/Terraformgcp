terraform {
     backend "gcs" {
       bucket = "ajitgcpterraform"
       prefix = "terraform/state"
     }
   }