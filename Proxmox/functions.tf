# Functions

resource "random_integer" "unique_id" {
  min = 1000
  max = 9999
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "random_id" "my_id" {
  byte_length = 8
}

resource "random_password" "my_password" {
  length  = 12
  special = true
}

resource "random_pet" "my_name" {
  length = 2
}

resource "random_uuid" "my_uuid" { }

resource "random_shuffle" "my_numbers" {
  input        = ["one", "two", "three", "four"]
}
