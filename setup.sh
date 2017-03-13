#!/bin/sh

aws cloudformation validate-template --template-body file://vault-core-networking.json
aws cloudformation validate-template --template-body file://vault-core-security.json
aws cloudformation validate-template --template-body file://vault-core-instances.json
aws cloudformation validate-template --template-body file://vault-core-dynamodb.json

aws cloudformation create-stack --stack-name "Hashicorp-Vault-Reference-Master" --template-body file://vault-core-networking.json --parameters file://vault-core-networking-parameters.json --capabilities CAPABILITY_IAM
aws cloudformation create-stack --stack-name "Hashicorp-Vault-Reference-Security" --template-body file://vault-core-security.json --parameters file://vault-core-security-parameters.json --capabilities CAPABILITY_IAM
aws cloudformation create-stack --stack-name "Hashicorp-Vault-Reference-Instances" --template-body file://vault-core-instances.json --parameters file://vault-core-instances-parameters.json --capabilities CAPABILITY_IAM
#aws cloudformation create-stack --stack-name "Hashicorp-Vault-Reference-DynamoDB" --template-body file://vault-core-dynamodb.json --capabilities CAPABILITY_IAM