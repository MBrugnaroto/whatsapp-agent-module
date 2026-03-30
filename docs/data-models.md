# Modelos de Dados

> Gerado em: 2026-03-30 | Scan Level: exhaustive

## Visão Geral

A Ava utiliza duas camadas de persistência de dados: **memória de curto prazo** (SQLite via LangGraph checkpointer) e **memória de longo prazo** (Qdrant vector database). Não há ORM tradicional ou migrações SQL — os modelos de dados são definidos via Pydantic e dataclasses Python.

---

## Modelos Pydantic

### 1. `Settings` — Configuração da Aplicação

**Arquivo:** `src/ai_companion/settings.py`  
**Base:** `pydantic_settings.BaseSettings`

Carrega configuração a partir do arquivo `.env`.

| Campo | Tipo | Padrão | Descrição |
|-------|------|--------|-----------|
| `GROQ_API_KEY` | `str` | — | Chave de API do Groq |
| `ELEVENLABS_API_KEY` | `str` | — | Chave de API do ElevenLabs |
| `ELEVENLABS_VOICE_ID` | `str` | — | ID da voz do ElevenLabs |
| `TOGETHER_API_KEY` | `str` | — | Chave de API do Together AI |
| `QDRANT_API_KEY` | `str \| None` | — | Chave de API do Qdrant |
| `QDRANT_URL` | `str` | — | URL da instância Qdrant |
| `QDRANT_PORT` | `str` | `"6333"` | Porta do Qdrant |
| `QDRANT_HOST` | `str \| None` | `None` | Host do Qdrant |
| `TEXT_MODEL_NAME` | `str` | `"llama-3.3-70b-versatile"` | Modelo LLM principal |
| `SMALL_TEXT_MODEL_NAME` | `str` | `"llama-3.1-8b-instant"` | Modelo LLM menor (extração de memória) |
| `STT_MODEL_NAME` | `str` | `"whisper-large-v3-turbo"` | Modelo Speech-to-Text |
| `TTS_MODEL_NAME` | `str` | `"eleven_flash_v2_5"` | Modelo Text-to-Speech |
| `TTI_MODEL_NAME` | `str` | `"black-forest-labs/FLUX.1-schnell-Free"` | Modelo Text-to-Image |
| `ITT_MODEL_NAME` | `str` | `"llama-3.2-90b-vision-preview"` | Modelo Image-to-Text (Vision) |
| `MEMORY_TOP_K` | `int` | `3` | Número de memórias relevantes a recuperar |
| `ROUTER_MESSAGES_TO_ANALYZE` | `int` | `3` | Mensagens a analisar no router |
| `TOTAL_MESSAGES_SUMMARY_TRIGGER` | `int` | `20` | Trigger para sumarização |
| `TOTAL_MESSAGES_AFTER_SUMMARY` | `int` | `5` | Mensagens retidas após sumarização |
| `SHORT_TERM_MEMORY_DB_PATH` | `str` | `"/app/data/memory.db"` | Caminho do SQLite |

---

### 2. `AICompanionState` — Estado do Grafo LangGraph

**Arquivo:** `src/ai_companion/graph/state.py`  
**Base:** `langgraph.graph.MessagesState`

Estado central do workflow do agente. Herda `messages` de `MessagesState`.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `messages` | `list[BaseMessage]` | Histórico de mensagens (herdado) |
| `summary` | `str` | Resumo da conversa para contexto |
| `workflow` | `str` | Tipo de workflow atual: `"conversation"`, `"image"` ou `"audio"` |
| `audio_buffer` | `bytes` | Buffer de áudio para TTS |
| `image_path` | `str` | Caminho da imagem gerada |
| `current_activity` | `str` | Atividade atual da Ava baseada no schedule |
| `apply_activity` | `bool` | Flag para aplicar contexto de atividade |
| `memory_context` | `str` | Contexto de memórias injetado no character card |

---

### 3. `RouterResponse` — Resposta do Router

**Arquivo:** `src/ai_companion/graph/utils/chains.py`  
**Base:** `pydantic.BaseModel`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `response_type` | `str` | Tipo de resposta: `"conversation"`, `"image"` ou `"audio"` |

---

### 4. `MemoryAnalysis` — Análise de Memória

**Arquivo:** `src/ai_companion/modules/memory/long_term/memory_manager.py`  
**Base:** `pydantic.BaseModel`

Resultado da análise de uma mensagem para conteúdo digno de memorização.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `is_important` | `bool` | Se a mensagem contém informação importante |
| `formatted_memory` | `Optional[str]` | Memória formatada para armazenamento |

---

### 5. `ScenarioPrompt` — Cenário de Imagem

**Arquivo:** `src/ai_companion/modules/image/text_to_image.py`  
**Base:** `pydantic.BaseModel`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `narrative` | `str` | Resposta narrativa da IA |
| `image_prompt` | `str` | Prompt visual para geração de imagem |

---

### 6. `EnhancedPrompt` — Prompt Melhorado

**Arquivo:** `src/ai_companion/modules/image/text_to_image.py`  
**Base:** `pydantic.BaseModel`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `content` | `str` | Prompt de texto melhorado para geração de imagem |

---

## Dataclasses

### 7. `Memory` — Entrada de Memória no Vector Store

**Arquivo:** `src/ai_companion/modules/memory/long_term/vector_store.py`  
**Tipo:** `dataclass`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `text` | `str` | Conteúdo textual da memória |
| `metadata` | `dict` | Metadados (id, timestamp, etc.) |
| `score` | `Optional[float]` | Score de similaridade (preenchido em buscas) |

**Propriedades:**
- `id` → `Optional[str]` — Extraído de `metadata["id"]`
- `timestamp` → `Optional[datetime]` — Extraído de `metadata["timestamp"]`

---

## Armazenamento Vetorial (Qdrant)

### Coleção: `long_term_memory`

| Propriedade | Valor |
|-------------|-------|
| **Nome** | `long_term_memory` |
| **Modelo de Embedding** | `all-MiniLM-L6-v2` (sentence-transformers) |
| **Dimensão do Vetor** | 384 (determinado pelo modelo) |
| **Métrica de Distância** | Cosine |
| **Threshold de Similaridade** | 0.9 (para detecção de duplicatas) |

**Payload do Ponto:**

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `text` | `string` | Texto da memória |
| `id` | `string` | UUID único |
| `timestamp` | `string` | ISO timestamp da criação |

---

## Memória de Curto Prazo (SQLite)

O LangGraph utiliza `AsyncSqliteSaver` como checkpointer para persistir o estado do grafo entre invocações.

| Propriedade | Valor |
|-------------|-------|
| **Tipo** | SQLite (via `langgraph-checkpoint-sqlite`) |
| **Caminho** | `/app/data/memory.db` (container) ou configurável via `SHORT_TERM_MEMORY_DB_PATH` |
| **Uso** | Persistência de estado do grafo, histórico de mensagens por `thread_id` |
| **Thread ID** | Número de telefone do WhatsApp (interface WhatsApp) ou `1` (interface Chainlit) |

---

## Exceções Personalizadas

**Arquivo:** `src/ai_companion/core/exceptions.py`

| Exceção | Uso |
|---------|-----|
| `SpeechToTextError` | Falha na conversão de áudio para texto |
| `TextToSpeechError` | Falha na conversão de texto para áudio |
| `TextToImageError` | Falha na geração de imagem |
| `ImageToTextError` | Falha na análise de imagem |
