storage "dynamodb" {
  ha_enabled = "true"
  max_parallel = 128
  region = "eu-west-1"
  table = "vault-data"
  read_capacity  = 10
  write_capacity = 15
}