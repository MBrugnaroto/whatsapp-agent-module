# Análise da Árvore de Código Fonte

> Gerado em: 2026-03-30 | Scan Level: exhaustive

## Estrutura do Repositório

```
ava-whatsapp-agent-course/
├── .env.example                    # Template de variáveis de ambiente
├── .gitignore                      # Regras de ignore (Python/IDE/projeto)
├── .pre-commit-config.yaml         # Hooks de pre-commit (Ruff linter/formatter)
├── docker-compose.yml              # Orquestração: Qdrant + Chainlit + WhatsApp
├── Dockerfile                      # Imagem Docker para interface WhatsApp (FastAPI)
├── Dockerfile.chainlit             # Imagem Docker para interface Chainlit
├── LICENSE                         # Licença MIT
├── Makefile                        # Comandos de build, run, lint, format
├── pyproject.toml                  # Metadados do projeto, dependências, config Ruff
├── README.md                       # Documentação principal do curso
├── uv.lock                         # Lockfile de dependências (uv)
│
├── docs/                           # Documentação do projeto
│   ├── GETTING_STARTED.md          # Guia de início rápido
│   └── gcp_setup.md               # Instruções de deploy no GCP Cloud Run
│
├── img/                            # Assets de imagem para README
│
├── notebooks/                      # Jupyter notebooks experimentais
│   ├── character_card.ipynb        # Experimentação com character card
│   └── router.ipynb               # Experimentação com router
│
└── src/                            # Código fonte principal
    └── ai_companion/              # Pacote principal da aplicação
        ├── settings.py            # ⚙️ Configuração centralizada (Pydantic Settings)
        │
        ├── core/                  # Núcleo da aplicação
        │   ├── exceptions.py      # Exceções personalizadas (STT, TTS, T2I, I2T)
        │   ├── prompts.py         # Templates de prompts (router, character, memória, imagem)
        │   └── schedules.py       # Agenda semanal da Ava (horário × atividade)
        │
        ├── graph/                 # 🧠 Motor do agente (LangGraph)
        │   ├── __init__.py        # Exporta graph_builder
        │   ├── graph.py           # Definição do StateGraph e fluxo de nós
        │   ├── nodes.py           # Nós do grafo (router, conversa, imagem, áudio, memória, sumário)
        │   ├── edges.py           # Edges condicionais (select_workflow, should_summarize)
        │   ├── state.py           # AICompanionState (estado do grafo)
        │   └── utils/
        │       ├── chains.py      # Chains LangChain (router chain, character chain)
        │       └── helpers.py     # Factory de modelos (ChatGroq), módulos (TTS, T2I)
        │
        ├── interfaces/            # 🔌 Interfaces de entrada/saída
        │   ├── chainlit/
        │   │   └── app.py         # Interface web Chainlit (texto, áudio, imagem)
        │   └── whatsapp/
        │       ├── webhook_endpoint.py  # Entry point FastAPI
        │       └── whatsapp_response.py # Webhook handler + integração WhatsApp Graph API
        │
        └── modules/               # 🔧 Módulos funcionais
            ├── image/
            │   ├── __init__.py    # Exporta ImageToText, TextToImage
            │   ├── image_to_text.py   # Análise de imagem via Groq Vision (VLM)
            │   └── text_to_image.py   # Geração de imagem via Together AI (FLUX)
            │
            ├── speech/
            │   ├── __init__.py    # Exporta SpeechToText, TextToSpeech
            │   ├── speech_to_text.py  # STT via Groq Whisper
            │   └── text_to_speech.py  # TTS via ElevenLabs
            │
            ├── schedules/
            │   └── context_generation.py  # Gerador de contexto de atividade por horário/dia
            │
            └── memory/
                └── long_term/
                    ├── memory_manager.py  # Gerenciador de memória (extração, armazenamento, recuperação)
                    └── vector_store.py    # Interface Qdrant (singleton, CRUD vetorial)
```

---

## Diretórios Críticos

### `src/ai_companion/graph/` — Motor do Agente

Diretório central que define o comportamento do agente usando LangGraph. Contém:
- **Definição do grafo** (`graph.py`): `StateGraph` com 8 nós e edges condicionais
- **Nós** (`nodes.py`): Router, injeção de contexto/memória, conversação, imagem, áudio, sumarização
- **Edges** (`edges.py`): Lógica de roteamento entre workflows e trigger de sumarização
- **Estado** (`state.py`): `AICompanionState` estendendo `MessagesState`

### `src/ai_companion/interfaces/` — Interfaces do Usuário

Duas interfaces de entrada:
- **Chainlit** (`chainlit/app.py`): UI web com streaming de respostas, suporte a áudio e imagem
- **WhatsApp** (`whatsapp/`): Webhook FastAPI para integração com WhatsApp Cloud API

### `src/ai_companion/modules/` — Módulos Funcionais

Módulos encapsulados para capacidades específicas:
- **Image**: Geração (Together FLUX) e análise (Groq Vision)
- **Speech**: STT (Groq Whisper) e TTS (ElevenLabs)
- **Memory**: Gerenciamento de memória de longo prazo via Qdrant
- **Schedules**: Geração de contexto de atividade baseado em horário

### `src/ai_companion/core/` — Núcleo Compartilhado

Templates de prompts, exceções e dados de agenda que são utilizados por múltiplos módulos.

---

## Entry Points

| Interface | Arquivo | Comando de Execução |
|-----------|---------|---------------------|
| **WhatsApp** (FastAPI) | `src/ai_companion/interfaces/whatsapp/webhook_endpoint.py` | `fastapi run ai_companion/interfaces/whatsapp/webhook_endpoint.py --port 8080` |
| **Chainlit** (Web UI) | `src/ai_companion/interfaces/chainlit/app.py` | `chainlit run ai_companion/interfaces/chainlit/app.py --port 8000` |
| **LangGraph Studio** | `src/ai_companion/graph/graph.py` | Grafo compilado exportado como `graph` |

---

## Estatísticas do Código

| Métrica | Valor |
|---------|-------|
| **Total de arquivos Python** | 23 |
| **Diretórios de código** | 9 |
| **Notebooks** | 2 |
| **Dockerfiles** | 2 |
| **Linhas de código (aprox.)** | ~1.200 (excluindo schedules e prompts longos) |
