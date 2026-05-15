# Terraform EC2 Provisioner

Provisiona instâncias EC2 na AWS com VPC, Subnets, Internet Gateway, Route Table e Security Group, usando módulos reutilizáveis por ambiente (DEV e PROD).

> **Aviso:** Este projeto é destinado a fins de estudo — para você subir instâncias na AWS e usá-las nos seus labs. Ele foi construído de forma que também é possível incorporá-lo em ambientes empresariais, bastando adaptar as variáveis e o backend de statefile.

---

## Estrutura

```
TerraformEC2Provisioner/
├── modules/
│   ├── vpc/             → VPC, subnets pública/privada, IGW, route table
│   ├── security_group/  → Security group com regras de acesso SSH/RDP
│   └── ec2/             → Instâncias EC2 com disco criptografado
└── environments/
    ├── prod/            → Módulo raiz do PROD
    └── dev/             → Módulo raiz do DEV
```

Os módulos em `modules/` são reutilizáveis e não rodam sozinhos — o Terraform é sempre executado dentro de `environments/prod` ou `environments/dev`.

---

## Como usar este projeto

### 1. Clone o repositório e crie as branches

```bash
git clone https://github.com/SEU_USUARIO/TerraformEC2Provisioner.git
cd TerraformEC2Provisioner

git checkout -b development
git push origin development

git checkout -b production
git push origin production
```

> As branches `development` e `production` são obrigatórias — o pipeline CI/CD (GitHub Actions) usa o nome da branch para saber qual ambiente provisionar. Um push para `development` executa o módulo `environments/dev`; um push para `production` executa o módulo `environments/prod`.

---

### 2. Pré-requisitos

#### Ferramentas (execução local)

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >= 1.4.0
- [AWS CLI](https://aws.amazon.com/pt/cli/) configurado com `aws configure`

> É necessário criar um usuário IAM na AWS com acesso via CLI. Configure esse usuário com as permissões abaixo, seguindo o princípio do menor privilégio:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSubnet",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DescribeInstances",
        "ec2:CreateKeyPair",
        "ec2:AttachInternetGateway",
        "ec2:DeleteRouteTable",
        "ec2:AssociateRouteTable",
        "ec2:DescribeInternetGateways",
        "ec2:StartInstances",
        "ec2:CreateRoute",
        "ec2:CreateInternetGateway",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DescribeVolumes",
        "ec2:DescribeAccountAttributes",
        "ec2:DeleteInternetGateway",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeRouteTables",
        "ec2:CreateTags",
        "ec2:CreateRouteTable",
        "ec2:RunInstances",
        "ec2:DetachInternetGateway",
        "ec2:DisassociateRouteTable",
        "ec2:StopInstances",
        "ec2:DescribeInstanceCreditSpecifications",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:GetPasswordData",
        "ec2:DescribeSecurityGroupRules",
        "ec2:DescribeInstanceTypes",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DescribeSubnets",
        "ec2:DeleteTags",
        "ec2:DescribeInstanceAttribute",
        "ec2:CreateVpc",
        "ec2:DescribeVpcAttribute",
        "ec2:ModifySubnetAttribute",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateSecurityGroup",
        "ec2:ModifyVpcAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:TerminateInstances",
        "ec2:DescribeTags",
        "ec2:DeleteRoute",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeImages",
        "ec2:DescribeVpcs",
        "ec2:DeleteSecurityGroup"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:CreateBucket",
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:PutBucketVersioning"
      ],
      "Resource": [
        "arn:aws:s3:::*-tfstate*",
        "arn:aws:s3:::*-tfstate*/*"
      ]
    }
  ]
}
```

#### Bucket S3 — state remoto

O Terraform salva o [state file](https://developer.hashicorp.com/terraform/language/state) em um bucket S3. Crie o bucket antes de rodar:

```bash
aws s3api create-bucket --bucket SEU_BUCKET-tfstate --region us-east-1
aws s3api put-bucket-versioning \
  --bucket SEU_BUCKET-tfstate \
  --versioning-configuration Status=Enabled
```

Depois configure o nome do bucket no backend de cada ambiente:

| Arquivo | Linha a alterar |
|---|---|
| `environments/prod/main.tf` | `bucket = "SEU_BUCKET-tfstate_PROD"` |
| `environments/dev/main.tf`  | `bucket = "SEU_BUCKET-tfstate_DEV"` |

> O nome do bucket deve conter `-tfstate`, conforme a restrição configurada nas permissões do usuário IAM.

#### Key Pair — acesso SSH e descriptografia de senha Windows

```bash
aws ec2 create-key-pair \
  --key-name NOME_DA_CHAVE \
  --query "KeyMaterial" \
  --output text > NOME_DA_CHAVE.pem

chmod 400 NOME_DA_CHAVE.pem
```

> A chave privada `.pem` é gerada **uma única vez**. A AWS não armazena a parte privada — guarde em lugar seguro.

---

### 3. Configuração das variáveis

As variáveis ficam nos arquivos `environments/dev/variables.tf` e `environments/prod/variables.tf`. Revise e ajuste cada uma conforme seu ambiente:

| Variável | Descrição |
|---|---|
| `service` | Nome do serviço/projeto, usado nas tags dos recursos |
| `myip` | Seu IP público em CIDR (ex: `1.2.3.4/32`) — libera acesso SSH/RDP apenas para você. Obtenha com `curl https://checkip.amazonaws.com` |
| `os_type` | Sistema operacional das instâncias: `AMAZON_LINUX_2023`, `UBUNTU_22_04`, `UBUNTU_24_04`, `WINDOWS_2019` ou `WINDOWS_2022` |
| `instance_count` | Quantidade de instâncias EC2 a subir no ambiente |
| `instance_type` | Tipo da instância EC2 (ex: `t3.micro`). Deve ser arquitetura x86_64 |
| `key_name` | Nome do Key Pair criado na etapa anterior |

> O `myip` também pode ser passado como secret do GitHub Actions (veja a seção de CI/CD abaixo), o que é a abordagem recomendada para não expor seu IP no código.

---

### 4. GitHub Actions — Secrets obrigatórios

O pipeline usa três secrets que devem ser configurados no repositório em **Settings → Secrets and variables → Actions**:

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Access Key do usuário IAM criado no passo 2 |
| `AWS_SECRET_ACCESS_KEY` | Secret Key do mesmo usuário |
| `MY_IP_CIDR` | Seu IP público em CIDR (ex: `1.2.3.4/32`) |

---

### 5. Deploy via GitHub Actions (fluxo principal)

Com tudo configurado, o deploy é feito simplesmente fazendo push para a branch correspondente ao ambiente:

```bash
# Sobe recursos no ambiente DEV
git checkout development
git push origin development

# Sobe recursos no ambiente PROD
git checkout production
git push origin production
```

O pipeline executa automaticamente:

1. **Checkov** — análise de segurança estática no código Terraform (detalhes abaixo)
2. **Terraform Init** — inicializa o backend e baixa os providers
3. **Terraform Apply** — provisiona a infraestrutura do ambiente correspondente

Para destruir os recursos, acesse **Actions → Terraform Destroy** no GitHub e selecione o ambiente desejado (DEV ou PROD). O destroy é manual e intencional — não acontece por push.

---

## Checkov — Análise de segurança estática

O [Checkov](https://www.checkov.io/) é uma ferramenta open source de análise estática para infraestrutura como código. Ele verifica o código Terraform antes de qualquer apply, identificando configurações que violam boas práticas de segurança.

**O que ele faz neste projeto:**

- Analisa todos os arquivos `.tf` em busca de vulnerabilidades e configurações incorretas
- Foca apenas em severidades **HIGH** e **CRITICAL** (ruídos de LOW/MEDIUM são ignorados)
- Roda como primeiro job do pipeline — se encontrar violações, o `terraform apply` não é executado

**Por que isso importa:**

Mesmo em ambientes de estudo, rodar o Checkov ajuda a desenvolver o hábito de escrever infraestrutura segura desde o início. Em ambientes empresariais, ele atua como gate obrigatório antes do deploy.

---

## Uso local (opcional)

Se preferir rodar o Terraform diretamente na sua máquina sem depender do CI/CD:

```bash
# Entre na pasta do ambiente desejado
cd environments/dev   # ou environments/prod

# Primeira vez (baixa providers e configura backend)
terraform init

# Visualiza o que será criado/alterado
terraform plan

# Aplica as mudanças
terraform apply

# Destrói toda a infraestrutura do ambiente
terraform destroy
```

---

## Acesso às instâncias

### Linux — SSH

```bash
# Pegue o IP público via output
terraform output public_ip

# Conecte com a chave .pem
ssh -i NOME_DA_CHAVE.pem ec2-user@IP_DA_INSTANCIA
```

### Windows — RDP

```bash
# Pegue o IP público
terraform output public_ip

# Descriptografe a senha de Administrator
aws ec2 get-password-data \
  --instance-id i-XXXXXXXXXXXXXXXXX \
  --priv-launch-key NOME_DA_CHAVE.pem \
  --query "PasswordData" \
  --output text
```

Conecte via RDP com:
- **Host:** IP público da instância
- **Usuário:** `Administrator`
- **Senha:** valor retornado acima

> A senha só fica disponível ~4 minutos após o boot. Se retornar vazio, aguarde e tente novamente.

> Se receber `Unable to decrypt password data using provided private key file`, sua chave pode estar no formato OpenSSH. Converta antes:
> ```bash
> cp NOME_DA_CHAVE.pem NOME_DA_CHAVE.pem.bak
> ssh-keygen -p -m PEM -f NOME_DA_CHAVE.pem
> ```

---

## Módulos

### `modules/vpc`

Cria a rede base do ambiente.

| Recurso | Nome na AWS |
|---|---|
| VPC | `VPC-{ambiente}` |
| Subnet pública | `SUBNET_PUBL-{ambiente}` |
| Subnet privada | `SUBNET_PRIV-{ambiente}` |
| Internet Gateway | `IGW-{ambiente}` |

**Outputs:** `vpc_id`, `subnet_public_id`, `subnet_private_id`, `aws_vpc_cidr_block`

### `modules/security_group`

Cria um security group com acesso SSH/RDP liberado para o CIDR da VPC e para o seu IP (`myip`).

**Outputs:** `security_group_id`

### `modules/ec2`

Cria `N` instâncias EC2 na subnet pública com disco criptografado.

- Nome das instâncias: `{OS_TYPE}-{ambiente}-001`, ex: `AMAZON_LINUX_2023-PROD-001`
- AMI buscada automaticamente via data source com base no `os_type`

**Outputs:** `public_ip[]`, `private_ip[]`, `instance_ids[]`, `instance_name[]`
