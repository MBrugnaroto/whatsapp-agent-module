# Arquitetura

> Gerado em: 2026-03-30 | Scan Level: exhaustive

## Resumo Executivo

A **Ava** é um agente de IA conversacional que opera como uma persona realista no WhatsApp, inspirado no filme Ex Machina. A arquitetura é centrada em um **grafo de estado LangGraph** que orquestra múltiplas capacidades multimodais: conversação textual, geração e análise de imagens, e processamento de voz. O sistema possui duas interfaces de entrada (WhatsApp webhook e Chainlit web UI) que convergem para o mesmo grafo de processamento.

---

## Stack Tecnológico

| Categoria | Tecnologia | Versão | Justificativa |
|-----------|-----------|--------|---------------|
| **Linguagem** | Python | ≥3.12 | Ecossistema ML/AI maduro, async nativo |
| **Framework Web** | FastAPI | ≥0.115.6 | API assíncrona de alto desempenho para webhook |
| **Framework de Agente** | LangGraph | ≥0.2.60 | Orquestração de workflows com estado persistente |
| **Chains/Prompts** | LangChain | ≥0.3.13 | Abstração de prompts e chains para LLMs |
| **LLM Principal** | Groq (Llama 3.3 70B) | — | Inferência rápida, modelo versátil |
| **LLM Secundário** | Groq (Llama 3.1 8B Instant) | — | Modelo leve para extração de memória |
| **Vision (VLM)** | Groq (Llama 3.2 90B Vision) | — | Análise de imagens recebidas |
| **Speech-to-Text** | Groq (Whisper Large v3 Turbo) | — | Transcrição de áudio recebido |
| **Text-to-Speech** | ElevenLabs | ≥1.50.3 | Síntese de voz realista |
| **Text-to-Image** | Together AI (FLUX.1-schnell-Free) | ≥1.3.10 | Geração de imagens de alta qualidade |
| **Vector Database** | Qdrant | ≥1.12.1 | Memória de longo prazo com busca semântica |
| **Embeddings** | sentence-transformers (all-MiniLM-L6-v2) | ≥3.3.1 | Embeddings para busca vetorial |
| **Memória de Curto Prazo** | SQLite (via LangGraph checkpoint) | — | Persistência de estado do grafo |
| **Validação** | Pydantic / Pydantic Settings | 2.10.0 | Configuração e modelos tipados |
| **UI Web** | Chainlit | ≥1.3.2 | Interface de chat com streaming |
| **HTTP Client** | httpx | (transitiva) | Comunicação com WhatsApp Graph API |
| **Containerização** | Docker + Docker Compose | — | Orquestração de serviços |
| **Deploy** | Google Cloud Run | — | Deploy serverless de containers |
| **Gerenciador de Pacotes** | uv | — | Resolução rápida de dependências |
| **Linter/Formatter** | Ruff | — | Linting e formatação de código |

---

## Padrão Arquitetural

### Arquitetura de Agente com Grafo de Estado

A aplicação segue o padrão **Agent-based Architecture with State Graph**, onde:

1. **Grafo de Estado (StateGraph)** é o core que define o fluxo de processamento
2. **Nós** encapsulam ações específicas (router, conversa, imagem, áudio, memória)
3. **Edges Condicionais** determinam o próximo nó baseado no estado
4. **Estado Persistente** mantém contexto entre invocações via checkpointer

```
┌─────────────────────────────────────────────────────────────────┐
│                        INTERFACES                                │
│  ┌──────────────────┐         ┌──────────────────────────┐      │
│  │  WhatsApp Webhook │         │     Chainlit Web UI      │      │
│  │  (FastAPI :8080)  │         │     (Chainlit :8000)     │      │
│  └────────┬─────────┘         └──────────┬───────────────┘      │
│           │                               │                      │
│           └───────────┬───────────────────┘                      │
│                       ▼                                          │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │               LANGGRAPH STATE GRAPH                         │  │
│  │                                                             │  │
│  │  START → memory_extraction → router → context_injection     │  │
│  │           → memory_injection → [workflow selector]          │  │
│  │                                    │                        │  │
│  │                    ┌───────────────┼───────────────┐        │  │
│  │                    ▼               ▼               ▼        │  │
│  │             conversation_node  image_node   audio_node      │  │
│  │                    │               │               │        │  │
│  │                    └───────────────┼───────────────┘        │  │
│  │                                    ▼                        │  │
│  │                         [should_summarize?]                 │  │
│  │                           │              │                  │  │
│  │                           ▼              ▼                  │  │
│  │                    summarize_node      END                  │  │
│  │                           │                                 │  │
│  │                           ▼                                 │  │
│  │                          END                                │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                     MÓDULOS                               │    │
│  │  ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌──────────────┐  │    │
│  │  │ Speech  │ │  Image   │ │ Memory  │ │  Schedules   │  │    │
│  │  │ STT/TTS │ │ I2T/T2I  │ │ Qdrant  │ │  Context     │  │    │
│  │  └─────────┘ └──────────┘ └─────────┘ └──────────────┘  │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                 SERVIÇOS EXTERNOS                         │    │
│  │  Groq │ ElevenLabs │ Together AI │ Qdrant │ WhatsApp API │    │
│  └──────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Fluxo de Processamento Detalhado

### 1. Recepção de Mensagem

A mensagem chega por uma das duas interfaces:
- **WhatsApp**: Webhook `POST /whatsapp_response` → parse do payload → download de mídia (se áudio/imagem) → transcrição/análise
- **Chainlit**: Event handlers `on_message` / `on_audio_end` → processamento de anexos

### 2. Execução do Grafo

O grafo é compilado com um `AsyncSqliteSaver` checkpointer e invocado com a mensagem:

1. **`memory_extraction_node`**: Analisa a última mensagem do usuário com `llama-3.1-8b-instant` para extrair fatos pessoais. Se encontrar informação relevante, armazena no Qdrant (com detecção de duplicatas por similaridade ≥0.9).

2. **`router_node`**: Usa `llama-3.3-70b` com structured output para classificar a intenção em: `conversation`, `image` ou `audio`.

3. **`context_injection_node`**: Consulta o `ScheduleContextGenerator` para determinar a atividade atual da Ava baseado no dia/hora. Marca se a atividade mudou desde a última mensagem.

4. **`memory_injection_node`**: Busca as top-3 memórias mais relevantes no Qdrant baseado no contexto recente (últimas 3 mensagens) e formata como bullet points para injeção no character card.

5. **Workflow selecionado** (via `select_workflow` edge):
   - **`conversation_node`**: Invoca character chain com contexto de atividade e memórias → resposta textual
   - **`image_node`**: Cria cenário narrativo → gera imagem via FLUX → invoca character chain com o cenário → retorna texto + imagem
   - **`audio_node`**: Invoca character chain → sintetiza áudio via ElevenLabs TTS → retorna texto + áudio

6. **`should_summarize_conversation`** (edge condicional): Se o número de mensagens exceder 20, executa `summarize_conversation_node` que cria um resumo e remove mensagens antigas (mantém as 5 mais recentes).

### 3. Envio de Resposta

- **WhatsApp**: Envia resposta via Graph API (texto, áudio uploadado ou imagem uploadada)
- **Chainlit**: Renderiza resposta com streaming (texto), player de áudio ou imagem inline

---

## Design do Character Card

A Ava opera sob um **character card** detalhado (`core/prompts.py`) que define:

- **Bio**: ML Engineer na Groq, de Boston, mora em San Francisco
- **Personalidade**: Autêntica, bem-humorada, casual, com humor peculiar
- **Regras**: Nunca revela ser IA, limita respostas a ~100 palavras, mistura respostas curtas e longas
- **Contexto dinâmico**: Atividade atual (agenda semanal detalhada) + memórias do usuário

A agenda semanal (`core/schedules.py`) cobre todos os 7 dias da semana com atividades horário a horário, criando uma ilusão de vida cotidiana.

---

## Padrões de Design Utilizados

| Padrão | Onde | Descrição |
|--------|------|-----------|
| **Singleton** | `VectorStore`, factory functions | Instância única para clientes de API |
| **Factory** | `helpers.py` | Criação de modelos e módulos |
| **State Machine** | `graph.py` | Grafo de estado com transições condicionais |
| **Strategy** | `edges.py` | Seleção dinâmica de workflow baseada no estado |
| **Chain of Responsibility** | Nós do grafo | Processamento sequencial com enriquecimento progressivo do estado |
| **Observer/Event** | Chainlit handlers | Callbacks para eventos de chat, áudio e mensagem |

---

## Decisões Arquiteturais

### Por que LangGraph em vez de LangChain Agents?

O LangGraph oferece controle explícito sobre o fluxo de execução via grafo de estado, diferente dos agents LangChain que são mais autônomos. Para um agente conversacional com workflows bem definidos (conversa/imagem/áudio), o grafo de estado é mais previsível e debugável.

### Por que duas interfaces separadas?

- **Chainlit**: Desenvolvimento e teste local com streaming e debug
- **WhatsApp**: Interface de produção para uso real, com deploy em Cloud Run

Ambas compartilham o mesmo `graph_builder`, garantindo comportamento consistente.

### Por que SQLite para memória de curto prazo?

O `AsyncSqliteSaver` do LangGraph é leve, não requer infraestrutura adicional e persiste o estado do grafo entre invocações. Cada conversa é isolada por `thread_id`.

### Por que Qdrant para memória de longo prazo?

Qdrant oferece busca vetorial eficiente para recuperar memórias relevantes por similaridade semântica, essencial para o character card contextualizado.

---

## Estratégia de Testes

O projeto **não possui suíte de testes automatizados**. A verificação é feita manualmente via interface Chainlit e WhatsApp. Pre-commit hooks com Ruff garantem qualidade de código (linting e formatação).

---

## Segurança e Autenticação

| Aspecto | Implementação |
|---------|---------------|
| **Webhook WhatsApp** | Verificação via `WHATSAPP_VERIFY_TOKEN` |
| **API Keys** | Gerenciadas via variáveis de ambiente (`.env`) |
| **Secrets em Produção** | Google Cloud Secret Manager |
| **Validação de Input** | Pydantic models com structured output |
