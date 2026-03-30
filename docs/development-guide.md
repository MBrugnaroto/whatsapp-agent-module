# Guia de Desenvolvimento

> Gerado em: 2026-03-30 | Scan Level: exhaustive

## Pré-requisitos

| Requisito | Versão | Notas |
|-----------|--------|-------|
| **Python** | ≥3.12 | Recomendado 3.12.8 |
| **uv** | Última versão | Gerenciador de pacotes ([instalação](https://docs.astral.sh/uv/getting-started/installation/)) |
| **Docker** + **Docker Compose** | Últimas versões | Para execução local completa |
| **Git** | Qualquer versão recente | Controle de versão |

---

## Instalação

### 1. Clonar o Repositório

```bash
git clone https://github.com/neural-maze/ava-whatsapp-agent-course.git
cd ava-whatsapp-agent-course
```

### 2. Criar Ambiente Virtual e Instalar Dependências

```bash
uv venv .venv

# macOS / Linux
source .venv/bin/activate

# Windows
.\.venv\Scripts\Activate.ps1

uv pip install -e .
```

### 3. Verificar Instalação

```bash
uv run python --version
# Esperado: Python 3.12.8
```

---

## Configuração do Ambiente

### Variáveis de Ambiente

```bash
cp .env.example .env
```

Preencher o arquivo `.env` com as chaves de API:

| Variável | Serviço | Como Obter |
|----------|---------|------------|
| `GROQ_API_KEY` | Groq | [Console Groq](https://console.groq.com/docs/quickstart) |
| `ELEVENLABS_API_KEY` | ElevenLabs | [Configurações da conta](https://elevenlabs.io/) |
| `ELEVENLABS_VOICE_ID` | ElevenLabs | Selecionar voz no dashboard |
| `TOGETHER_API_KEY` | Together AI | [Configurações da conta](https://www.together.ai/) |
| `QDRANT_URL` | Qdrant | [Qdrant Cloud](https://login.cloud.qdrant.io/) ou `http://localhost:6333` (local) |
| `QDRANT_API_KEY` | Qdrant | Dashboard Qdrant Cloud (pode ser `None` localmente) |
| `WHATSAPP_PHONE_NUMBER_ID` | Meta/WhatsApp | Configuração do WhatsApp Business API |
| `WHATSAPP_TOKEN` | Meta/WhatsApp | Token de acesso do WhatsApp Business |
| `WHATSAPP_VERIFY_TOKEN` | Meta/WhatsApp | Token personalizado para verificação do webhook |

---

## Execução Local

### Via Docker Compose (Recomendado)

```bash
# Build e execução
make ava-run

# Apenas build
make ava-build

# Parar serviços
make ava-stop

# Parar e limpar dados
make ava-delete
```

Serviços disponíveis após `make ava-run`:

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **Qdrant** | http://localhost:6333/dashboard | Interface do banco vetorial |
| **Chainlit** | http://localhost:8000 | Interface web de chat |
| **FastAPI** | http://localhost:8080/docs | Webhook WhatsApp + Swagger UI |

### Execução Individual (Desenvolvimento)

```bash
# Chainlit (interface web)
chainlit run src/ai_companion/interfaces/chainlit/app.py --port 8000

# FastAPI (webhook WhatsApp)
fastapi run src/ai_companion/interfaces/whatsapp/webhook_endpoint.py --port 8080
```

---

## Estrutura de Dependências

### Dependências Principais

| Pacote | Uso |
|--------|-----|
| `fastapi[standard]` | Framework web para webhook |
| `chainlit` | Interface web de chat |
| `langgraph` | Orquestração do agente |
| `langchain` / `langchain-groq` / `langchain-openai` | Chains e integração LLM |
| `langchain-community` | Componentes da comunidade LangChain |
| `pydantic` / `pydantic-settings` | Validação de dados e configuração |
| `groq` | SDK direto do Groq (STT, Vision) |
| `elevenlabs` | SDK do ElevenLabs (TTS) |
| `together` | SDK do Together AI (geração de imagem) |
| `qdrant-client` | Cliente do Qdrant |
| `sentence-transformers` | Modelo de embeddings |
| `torch` / `numpy` | Dependências do sentence-transformers |
| `langgraph-checkpoint-sqlite` / `aiosqlite` | Checkpointer SQLite assíncrono |
| `langgraph-checkpoint-duckdb` / `duckdb` | Checkpointer DuckDB (alternativo) |
| `supabase` | Cliente Supabase (disponível, não usado ativamente) |
| `httpx` | HTTP client assíncrono (WhatsApp Graph API) |

---

## Comandos de Qualidade de Código

### Formatação

```bash
# Aplicar formatação
make format-fix

# Verificar formatação (CI)
make format-check
```

### Linting

```bash
# Corrigir problemas de lint
make lint-fix

# Verificar lint (CI)
make lint-check
```

### Configuração Ruff

| Setting | Valor |
|---------|-------|
| Target version | Python 3.12 |
| Line length | 120 |
| Rules | E (errors), F (pyflakes), W (warnings), Q (quotes), I (isort) |
| Ignored | E501 (line too long) |

### Pre-commit Hooks

O projeto usa `pre-commit` com hooks do Ruff:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.3.4
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
      - id: ruff-format
```

---

## Fluxo de Desenvolvimento

### Adicionar uma Nova Capacidade ao Agente

1. **Criar módulo** em `src/ai_companion/modules/` com classe encapsulada
2. **Adicionar prompts** em `src/ai_companion/core/prompts.py`
3. **Criar nó** no grafo em `src/ai_companion/graph/nodes.py`
4. **Registrar nó** no `StateGraph` em `src/ai_companion/graph/graph.py`
5. **Adicionar edge** condicional se necessário em `edges.py`
6. **Atualizar estado** se novos campos forem necessários em `state.py`
7. **Integrar nas interfaces** (`chainlit/app.py` e/ou `whatsapp/whatsapp_response.py`)

### Modificar Persona da Ava

- **Character card**: Editar `CHARACTER_CARD_PROMPT` em `core/prompts.py`
- **Agenda**: Editar schedules em `core/schedules.py`
- **Configuração de modelos**: Ajustar em `settings.py`

---

## Troubleshooting Comum

| Problema | Solução |
|----------|---------|
| `.env file is missing` | Criar `.env` a partir de `.env.example` |
| Erro de API key | Verificar se todas as variáveis estão preenchidas no `.env` |
| Qdrant connection refused | Verificar se o serviço Qdrant está rodando (`docker compose up qdrant`) |
| Torch/NumPy incompatível | Verificar constraints de plataforma no `pyproject.toml` (Intel Mac vs outros) |
| Áudio não funciona | Verificar `ELEVENLABS_API_KEY` e `ELEVENLABS_VOICE_ID` |
