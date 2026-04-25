# Terraform EC2 Provisioner

Provisiona instâncias EC2 na AWS com VPC, Subnets, Internet Gateway, Route Table e Security Group, usando módulos reutilizáveis por ambiente (DEV e PROD).

---

## Estrutura

```
TerraformEC2Provisioner/
├── modules/
│   ├── vpc/             → VPC, subnets pública/privada, IGW, route table
│   ├── security_group/  → Security group com regras de acesso SSH
│   └── ec2/             → Instâncias EC2 com disco criptografado
└── environments/
    ├── prod/            → Ponto de entrada do PROD (terraform apply aqui)
    └── dev/              → Ponto de entrada do DEV  (terraform apply aqui)
```

Os módulos em `modules/` são reutilizáveis e não rodam sozinhos — o Terraform é sempre executado dentro de `environments/prod` ou `environments/dev`.

---

## Pré-requisitos

### 1. Ferramentas

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >= 1.4.0
- [AWS CLI](https://aws.amazon.com/pt/cli/) configurado com `aws configure`

### 2. Recursos AWS que precisam existir antes do deploy

#### Bucket S3 — state remoto
O Terraform salva o [state file](https://developer.hashicorp.com/terraform/language/state) em um bucket S3. Crie um bucket antes de rodar:

```bash
aws s3api create-bucket --bucket SEU_BUCKET --region us-east-1
aws s3api put-bucket-versioning \
  --bucket SEU_BUCKET \
  --versioning-configuration Status=Enabled
```

Depois configure o nome do bucket no backend de cada ambiente:

| Arquivo | Linha a alterar |
|---|---|
| `environments/prod/main.tf` | `bucket = "SEU_BUCKET_PROD"` |
| `environments/dev/main.tf`   | `bucket = "SEU_BUCKET_DEV"` |

#### Key Pair — acesso SSH às instâncias
Crie um Key Pair na AWS e salve a chave privada (`.pem`) localmente:

```bash
aws ec2 create-key-pair \
  --key-name NOME_DA_CHAVE \
  --query "KeyMaterial" \
  --output text > NOME_DA_CHAVE.pem

chmod 400 NOME_DA_CHAVE.pem
```

> A chave privada `.pem` é gerada **uma única vez**. Guarde em lugar seguro — a AWS não armazena a parte privada.

Configure o nome da chave no `terraform.tfvars` de cada ambiente (ver seção abaixo).

---

## Configuração por ambiente

Copie o arquivo de exemplo e preencha com seus valores:

```bash
# DEV
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars

# PROD
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
```

### Variáveis obrigatórias

| Variável | Onde usar | Como obter / Valores aceitos |
|---|---|---|
| `myip` | DEV e PROD | Seu IP público: `curl https://checkip.amazonaws.com` — adicione `/32` no final (ex: `1.2.3.4/32`) |
| `os_type` | DEV e PROD | `AMAZON_LINUX_2023`, `UBUNTU_22_04`, `UBUNTU_24_04`, `WINDOWS_2019`, `WINDOWS_2022` |
| `key_name` | DEV e PROD | Nome do Key Pair criado na etapa anterior |

### Variáveis opcionais (têm default)

| Variável | Default DEV | Default PROD | Descrição |
|---|---|---|---|
| `instance_count` | `2` | `3` | Quantidade de instâncias EC2 |
| `instance_type` | `t3.micro` | `t3.micro` | Tipo da instância (deve ser x86_64) |
| `environment` | `DEV` | `PROD` | Nome do ambiente usado nas tags |

### Exemplo de `terraform.tfvars`

```hcl
myip           = "1.2.3.4/32"
os_type        = "AMAZON_LINUX_2023"
key_name       = "minha-chave"
instance_count = 2
instance_type  = "t3.micro"
```

> `terraform.tfvars` está no `.gitignore` — nunca é enviado ao repositório.

---

## Uso local

```bash
# Entre na pasta do ambiente desejado
cd environments/qa   # ou environments/prod

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

## CI/CD (GitHub Actions)

| Workflow | Trigger | O que faz |
|---|---|---|
| **DEV** | push em `staging` | init → fmt check → validate → plan → apply |
| **DEV Destroy** | manual (`workflow_dispatch`) | destroy do ambiente DEV |
| **PROD CI** | pull request para `main` | init → fmt check → validate → plan (resultado postado como comentário no PR) |
| **PROD CD** | merge/push em `main` | init → plan → apply |
| **PROD Destroy** | manual (`workflow_dispatch`) | destroy do ambiente PROD |

Para rodar um destroy: vá em **Actions → escolha o workflow de Destroy → Run workflow** e informe o `os_type` usado no deploy.

### Secrets necessários no GitHub

Os secrets ficam separados por **Environment** (`DEV` e `PROD`), permitindo usar contas ou usuários AWS diferentes por ambiente.

Vá em *Settings → Environments → (selecione o environment) → Add environment secret* e adicione em cada um:

| Secret | Valor |
|---|---|
| `AWS_ACCESS_KEY_ID` | Access key do usuário AWS do ambiente |
| `AWS_SECRET_ACCESS_KEY` | Secret key do usuário AWS do ambiente |
| `MY_IP_CIDR` | Seu IP em formato CIDR (ex: `1.2.3.4/32`) |

> Para criar os environments: *Settings → Environments → New environment* → crie `DEV` e `PROD`.

---

## Módulos

### `modules/vpc`

Cria a rede base do ambiente.

| Recurso criado | Nome na AWS |
|---|---|
| VPC | `VPC-{ambiente}` |
| Subnet pública | `SUBNET_PUBL-{ambiente}` |
| Subnet privada | `SUBNET_PRIV-{ambiente}` |
| Internet Gateway | `IGW-{ambiente}` |
| Route Table | — |

**Outputs:** `vpc_id`, `subnet_public_id`, `subnet_private_id`, `aws_vpc_cidr_block`

---

### `modules/security_group`

Cria um security group com acesso SSH liberado para o CIDR da VPC e para o seu IP (`myip`).

**Outputs:** `security_group_id`

---

### `modules/ec2`

Cria `N` instâncias EC2 na subnet pública com disco criptografado.

- Nome das instâncias: `{OS_TYPE}-{ambiente}-001`, ex: `AMAZON_LINUX_2023-PROD-001`
- AMI: definida pelo ambiente (data source dinâmico no DEV, variável fixa no PROD)

**Outputs:** `public_ip[]`, `instance_ids[]`

---

## Acesso SSH às instâncias Linux

Após o apply, pegue o IP público via output:

```bash
terraform output public_ip
```

Conecte usando a chave `.pem`:

```bash
ssh -i NOME_DA_CHAVE.pem ec2-user@IP_DA_INSTANCIA
```

---

## Acesso RDP às instâncias Windows

Após o apply, pegue o IP público via output:

```bash
terraform output public_ip
```

Descriptografe a senha de Administrator com sua chave `.pem`:

```bash
aws ec2 get-password-data \
  --instance-id i-XXXXXXXXXXXXXXXXX \
  --priv-launch-key NOME_DA_CHAVE.pem \
  --query "PasswordData" \
  --output text
```

> A senha só fica disponível ~4 minutos após o boot. Se retornar vazio, aguarde e tente novamente.

> Se receber o erro `Unable to decrypt password data using provided private key file`, sua chave pode estar no formato OpenSSH. Converta para PEM antes de rodar o comando:
> ```bash
> cp NOME_DA_CHAVE.pem NOME_DA_CHAVE.pem.bak
> ssh-keygen -p -m PEM -f NOME_DA_CHAVE.pem
> ```

Conecte via RDP com:

- **Host:** IP público da instância
- **Usuário:** `Administrator`
- **Senha:** valor retornado pelo comando acima

