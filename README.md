# Terraform

## Overview

Terraform is infrastructure as code tool. It lets you define resources and infrastructure in
human-readable, declarative configuration files, and manages your infrastructure's lifecycle.

## Install

1. Install common packages

    ```shell
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    ```

2. Install HashiCorp GPG key

    - Add the key

    ```shell
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    ```

    - Verify the key

    ```shell
    gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint
    ```

3. Add official repository

    ```shell
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    ```

4. Install Terraform

    ```shell
    sudo apt update && sudo apt-get install terraform
    ```

## Usage

| Command                                 | Description                                           |
| --------------------------------------- | ----------------------------------------------------- |
| `terraform init`                        | Scaffold out required files for new/existing project. |
| `terraform fmt`                         | Format and linting of `.tf` files.                    |
| `terraform validate`                    | Validate your configuration.                          |
| [`terraform apply`](#terraform-apply)   | Apply the configuration.                              |
| `terraform show`                        | Inspect the current state.                            |
| `terraform state`                       | Advance state management.                             |
| [`terraform output`](#terraform-output) | Print output data to terminal.                        |
| `terraform destroy`                     | Terminate resources managed by project.               |

### Terraform apply

Terraform writes into a file called `terraform.tfstate`.
This file stores IDs and properties that the resources manages. @see [storing state remotely](https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-migrate)
`terraform.tfstate` contains sensitive information therefore restrict access.

Terraform will attempt to apply changes to the existing state. Depending on the provider, this may
not be possible (Docker port change). In such a case, Terraform will `destroy` and `apply` the new state.

### Terraform Output

Terraform `outputs.tf` is where you define dynamic variables, such as the values of "(known after apply)".

```conf

output "image_id" {
  description = "ID of the Docker image"
  value       = docker_image.nginx.id
}
```

## Configuration

### Variables

Terraform automatically loads all `.tf` files.
A `variables.tf` file stores project variables as

Below, we define a variable called `container_name` with a `string` value of "ExampleNginxContainer".

```conf
variable "container_name" {
  description = "Value of the name for the Docker container"
  type        = string
  default     = "ExampleNginxContainer"
}
```

Below, we use `var.container_name` variable as the resource name for Docker container.

```conf
resource "docker_container" "nginx" {
  name  = var.container_name
  ...
```

#### Dynamic variables

A `secret.tfvars` can act as an `.env` file and store secrets.

```conf
# secret.tfvars
db_username = "admin"
db_password = "insecure-password"
```

To redact variables, set `sensitive=true`.

```conf
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

Apply the variable file to current state.

```shell
terraform apply -var-file="secret.tfvars"
```

#### Override variables

Variables overridden via CLI are NOT persisted.

```shell
terraform apply -var 'container_name=YetAnotherName'
```
