# A reference architecture for [Hashicorp Vault](https://github.com/hashicorp/vault) on AWS
This project aims to show how to build an secure and resilient impementation of Vault on the AWS platform, consumed by a simple web application that includes some good security coding practises.
Hopefully this will help you get the best out of your Vault out of your projects. The project is licensed under the Apache v2.0 license, so you are free to use or modify it however you like, but we don't offer any kind of warranty!

## Overview ##

Vault is a good fit for a few use cases. The main one we are looking at is for a running application. This solves a few problems:

* It protects agains the insider threat of rogue admins/operators abusing DB credentials. This is a hard issue to solve in traditional ways and in the end the mitigation comes down to auditing DB logs for unusual activity. That is obviously a bit late because the damage has already been done by the time you look at the logs..
* It automates credential rotation, making it easy to comply with your crypto key management best practises
* It removes the need to store credentials in potentially insecure config files or similar

Here is the overall architecture:

![Architecure Overview](/images/Vault Reference Architecture.png)

Some key features:

* If the Vault fails, any dependent application fails too, so it is multi AZ and multi-server in each AZ
* The storage backend must also support HA (we have chosen [DynamoDB](https://www.vaultproject.io/docs/config/#dynamodb))
* The [MySQL secret backend](https://www.vaultproject.io/docs/secrets/mssql/index.html) generates credentials on the fly so it needs access to the DB. We are using VPG Gateways to lock down access to the DB
* We are using the [AWS EC2 Auth backend](https://www.vaultproject.io/docs/auth/aws-ec2.html) so that we can make use of [IAM roles](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) to control access to the Vault

## Infrastructure ##

To do:

* Network
* Components
* Deployment/CloudFormation

## Vault config ##

To do: 

* Initialisation
* Storage backend
* Audit backend
* MySQL secret backend

## IAM policies ##

To do:

* Normal privilege
* High privilege

## The client application ##

To do:

* Making the app "vault aware"
* Dynamic privilege elevation

## About the authors ##
We are not affiliated to Hashicorp or the Vault project in any way and any recommendations made are our own and not endorsed by Hashicorp. We just like Vault, AWS, security and messing about with cool tech :-)


