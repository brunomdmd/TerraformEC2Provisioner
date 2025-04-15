# Terraform EC2 Provisioner per Environment
    
## Objetivo
Esse projeto faz parte de um processo de aprendizagem que estou me subimentendo em Terraform, desculpe qualquer erro ou "prática ruim" no código, vamos melhorar! :)

## Features
- Deploy instâncias EC2, VPC, Subnet, Internet Gateway, Route Table e Security Group na AWS utilizando o Terraform
- Utilização de módulos reutilizáveis
- Flexivel para aplicação em ambientes diferentes, exemplo QA ou Produção.


## Pré Requisitos
- Configurar as credencias de acesso a AWS com o utilitário "aws configure" utilizando o [AWS CLI](https://aws.amazon.com/pt/cli/)
- Instalar o [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


## Configurações
- Alterar o nome do bucket do state file (`linha 8` do arquivo `main.tf` de cada módulo pai)
- Configurar uma `key pair` para cada ambiente e alterar o nome no arquivo `main.tf` de cada módulo pai.


## Utilização
- Navegar até a pasta do ambiente que queria subir (PROD ou QA)
- Iniciar o terraform
``
terraform init
``

- Planejar o terraform
``
terraform plan -out=plano
``

- Aplicar o terraform
``
 terraform apply "plano"
``
