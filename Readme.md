# Azure Functions Terraform sample

This is a sample script for deploying Azure Functions with Terraform.

* terraform scripts
* Azure Functions

## Terraform scripts

Deploy Function App with a function.

Just download Terraform from [here](https://www.terraform.io/downloads.html) and set path to the binary. Then

```
terraform init
terraform plan
terraform apply
```

You can copy the `terraform.tfvars.example` to `terraform.tfvars` then change the configuration according to your environment. 

_terraform.tfvars_

```
# Service Principle
subscription_id     = "YOUR_SUBSCRIPTION_ID"
client_id           = "YOUR_CLIENT_ID"
client_secret       = "YOUR_CLIENT_SECRET"
tenant_id           = "YOUR_TENANT_ID"

# Resource Group
resource_group      = "MyResourceGroup"
location            = "japaneast"
environment         = "test"

# Function App
function_app_name   = "YOUR_FUNCTIONAPP_NAME"
``` 

## Azure Functions

Please deploy Azure Function from this repo. Then install it to the Function App.

I want to automatically install using `Run-From-Zip` deployment with terraform. 

* [TsuyoshiUshio/EndPoint](https://github.com/TsuyoshiUshio/EndPoint)

However, `Run-From-Zip` is only limied for some regions, Now it is comment out now until it comes to your region. Until then, you can use `az` command execution instead. In this case, you can put your function with zipped with the name `function.zip`. 

