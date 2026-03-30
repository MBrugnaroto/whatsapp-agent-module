# Guia de Deploy

> Gerado em: 2026-03-30 | Scan Level: exhaustive

## Visão Geral

A Ava pode ser implantada de duas formas:

1. **Local**: Via Docker Compose (desenvolvimento e testes)
2. **Cloud**: Via Google Cloud Run (produção)

---

## Deploy Local (Docker Compose)

### Arquitetura de Serviços

O `docker-compose.yml` define três serviços:

| Serviço | Imagem/Dockerfile | Porta | Descrição |
|---------|-------------------|-------|-----------|
| `qdrant` | `qdrant/qdrant:latest` | 6333 | Banco vetorial para memória de longo prazo |
| `chainlit` | `Dockerfile.chainlit` | 8000 | Interface web de chat |
| `whatsapp` | `Dockerfile` | 8080 | Webhook FastAPI para WhatsApp |

### Dependências entre Serviços

```
chainlit  ──depends_on──▶  qdrant
whatsapp  ──depends_on──▶  qdrant
```

### Volumes

| Volume | Container | Host | Descrição |
|--------|-----------|------|-----------|
| Qdrant storage | `/qdrant/storage` | `./long_term_memory` | Dados persistentes do Qdrant |
| Short-term memory | `/app/data` | `./short_term_memory` | SQLite de memória de curto prazo |

### Variáveis de Ambiente (Docker)

Configuradas via `env_file: .env` com overrides no `docker-compose.yml`:

| Variável | Valor Override | Razão |
|----------|---------------|-------|
| `QDRANT_PORT` | `6333` | Porta interna do container |
| `QDRANT_API_KEY` | `None` | Sem auth em ambiente local |
| `QDRANT_HOST` | `localhost` | — |
| `QDRANT_URL` | `http://qdrant:6333` | Resolução DNS do Docker |

### Comandos

```bash
# Build e iniciar todos os serviços
make ava-run

# Apenas build das imagens
make ava-build

# Parar serviços (manter dados)
make ava-stop

# Parar serviços e limpar dados locais
make ava-delete
```

O `make ava-delete` remove:
- `long_term_memory/` (dados do Qdrant)
- `short_term_memory/` (SQLite)
- `generated_images/` (imagens geradas)

---

## Dockerfiles

### `Dockerfile` (WhatsApp / FastAPI)

| Propriedade | Valor |
|-------------|-------|
| **Base** | `ghcr.io/astral-sh/uv:python3.12-bookworm-slim` |
| **Porta** | 8080 |
| **Comando** | `fastapi run ai_companion/interfaces/whatsapp/webhook_endpoint.py --port 8080 --host 0.0.0.0` |
| **Build deps** | `build-essential`, `g++` |
| **Volume** | `/app/data` |

### `Dockerfile.chainlit` (Chainlit Web UI)

| Propriedade | Valor |
|-------------|-------|
| **Base** | `ghcr.io/astral-sh/uv:python3.12-bookworm-slim` |
| **Porta** | 8000 |
| **Comando** | `chainlit run ai_companion/interfaces/chainlit/app.py --port 8000 --host 0.0.0.0` |
| **Build deps** | `build-essential`, `g++` |
| **Volume** | `/app/data` |

---

## Deploy em Google Cloud Run

### Pré-requisitos

- Conta Google Cloud Platform (GCP)
- CLI `gcloud` instalada e autenticada
- Projeto GCP criado

### Passos de Configuração

#### 1. Autenticação

```bash
gcloud auth login
gcloud config set project <PROJECT_ID>
```

#### 2. Habilitar APIs Necessárias

```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable secretmanager.googleapis.com
```

#### 3. Configurar Docker Registry

```bash
gcloud config set compute/region <LOCATION>
gcloud auth configure-docker <LOCATION>-docker.pkg.dev -q
```

#### 4. Criar Repositório Docker

```bash
gcloud artifacts repositories create ava-app \
    --repository-format=docker \
    --location=<LOCATION> \
    --description="Docker repository for Ava, the WhatsApp Agent" \
    --project=<PROJECT_ID>
```

#### 5. Configurar Secrets

Todas as variáveis de ambiente devem ser criadas como secrets no Secret Manager:

```bash
echo -n "<valor>" | gcloud secrets create <NOME_DO_SECRET> \
    --replication-policy="automatic" \
    --data-file=-
```

**Secrets necessários:**
- `GROQ_API_KEY`
- `ELEVENLABS_API_KEY`
- `ELEVENLABS_VOICE_ID`
- `TOGETHER_API_KEY`
- `QDRANT_URL`
- `QDRANT_API_KEY`
- `WHATSAPP_PHONE_NUMBER_ID`
- `WHATSAPP_TOKEN`
- `WHATSAPP_VERIFY_TOKEN`

#### 6. Permissões de Acesso aos Secrets

```bash
gcloud projects add-iam-policy-binding <PROJECT_ID> \
    --member="serviceAccount:$(gcloud projects describe $(gcloud config get-value project) \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"
```

#### 7. Deploy

```bash
gcloud builds submit --region=<LOCATION>
```

---

## Requisitos de Infraestrutura

### Ambiente Local

| Recurso | Requisito |
|---------|-----------|
| **RAM** | ≥4GB (sentence-transformers carrega modelo em memória) |
| **Disco** | ~2GB (imagens Docker + modelos de embedding) |
| **CPU** | Qualquer CPU moderna |
| **GPU** | Não necessário (inferência via APIs externas) |

### Ambiente Cloud (Cloud Run)

| Recurso | Recomendação |
|---------|-------------|
| **Memória** | ≥2GB por instância |
| **CPU** | 1-2 vCPUs |
| **Concorrência** | Baixa (1-10 requests simultâneos) |
| **Qdrant** | Instância Qdrant Cloud separada |

---

## Considerações de Segurança em Produção

| Aspecto | Recomendação |
|---------|-------------|
| **Secrets** | Usar Google Cloud Secret Manager (nunca hardcoded) |
| **HTTPS** | Cloud Run fornece HTTPS automaticamente |
| **Webhook** | Verificação via `WHATSAPP_VERIFY_TOKEN` |
| **Rate Limiting** | Não implementado — considerar adicionar para produção |
| **Logging** | Logs via `logging` module → Cloud Logging no GCP |
