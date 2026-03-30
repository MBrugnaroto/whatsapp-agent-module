# Contratos de API

> Gerado em: 2026-03-30 | Scan Level: exhaustive

## Visão Geral

A aplicação expõe uma única API REST via **FastAPI**, responsável pela integração com a **WhatsApp Cloud API**. Não há API REST pública de uso geral — a API serve exclusivamente como webhook para receber e responder mensagens do WhatsApp.

Além disso, a interface **Chainlit** (porta 8000) fornece uma UI web para interação direta, mas não expõe endpoints REST documentáveis.

---

## Endpoints

### 1. WhatsApp Webhook

**Arquivo:** `src/ai_companion/interfaces/whatsapp/whatsapp_response.py`

#### `GET /whatsapp_response` — Verificação do Webhook

Endpoint utilizado pelo Meta/WhatsApp para verificar a propriedade do webhook.

| Campo | Valor |
|-------|-------|
| **Método** | `GET` |
| **Path** | `/whatsapp_response` |
| **Autenticação** | Token de verificação via query parameter |

**Query Parameters:**

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `hub.verify_token` | `string` | Token de verificação configurado no WhatsApp Business |
| `hub.challenge` | `string` | Challenge string retornada se o token for válido |
| `hub.mode` | `string` | Deve ser `subscribe` |

**Respostas:**

| Status | Descrição |
|--------|-----------|
| `200` | Retorna o `hub.challenge` como corpo da resposta |
| `403` | Token de verificação não corresponde |

---

#### `POST /whatsapp_response` — Processamento de Mensagens

Recebe notificações de mensagens e atualizações de status da WhatsApp Cloud API.

| Campo | Valor |
|-------|-------|
| **Método** | `POST` |
| **Path** | `/whatsapp_response` |
| **Content-Type** | `application/json` |
| **Autenticação** | Gerenciada pelo WhatsApp Cloud API (token no server-side) |

**Tipos de Mensagem Suportados:**

| Tipo | Processamento |
|------|---------------|
| `text` | Conteúdo extraído de `message.text.body` |
| `audio` | Download via Graph API → transcrição via Groq Whisper (STT) |
| `image` | Download via Graph API → análise via Groq Vision (VLM) + caption opcional |

**Tipos de Resposta (determinados pelo Router do LangGraph):**

| Workflow | Ação |
|----------|------|
| `conversation` | Envia resposta em texto via WhatsApp |
| `audio` | Gera áudio via ElevenLabs TTS → upload de mídia → envia via WhatsApp |
| `image` | Gera imagem via Together AI FLUX → upload de mídia → envia via WhatsApp |

**Respostas:**

| Status | Descrição |
|--------|-----------|
| `200` | Mensagem processada com sucesso / Status update recebido |
| `400` | Tipo de evento desconhecido |
| `500` | Erro interno ou falha no envio |

---

## Funções Auxiliares Internas

### `download_media(media_id: str) -> bytes`

Faz download de mídia (áudio/imagem) do WhatsApp via Graph API v21.0.

### `process_audio_message(message: Dict) -> str`

Baixa e transcreve mensagens de áudio usando Groq Whisper.

### `send_response(from_number, response_text, message_type, media_content) -> bool`

Envia resposta ao usuário via WhatsApp Graph API v21.0. Suporta texto, áudio e imagem.

### `upload_media(media_content: BytesIO, mime_type: str) -> str`

Faz upload de mídia para servidores do WhatsApp e retorna o `media_id`.

---

## APIs Externas Consumidas

| Serviço | Base URL | Uso |
|---------|----------|-----|
| **WhatsApp Graph API** | `https://graph.facebook.com/v21.0/` | Download/upload de mídia, envio de mensagens |
| **Groq API** | Via SDK `ChatGroq` / `Groq` | LLM (Llama 3.3), STT (Whisper), Vision (Llama 3.2 Vision) |
| **ElevenLabs API** | Via SDK `ElevenLabs` | Text-to-Speech (modelo `eleven_flash_v2_5`) |
| **Together AI API** | Via SDK `Together` | Geração de imagens (FLUX.1-schnell-Free) |
| **Qdrant** | Configurável via `QDRANT_URL` | Armazenamento e busca vetorial (memória de longo prazo) |

---

## Variáveis de Ambiente para API

| Variável | Uso |
|----------|-----|
| `WHATSAPP_TOKEN` | Bearer token para WhatsApp Graph API |
| `WHATSAPP_PHONE_NUMBER_ID` | ID do número de telefone do WhatsApp Business |
| `WHATSAPP_VERIFY_TOKEN` | Token de verificação do webhook |
| `GROQ_API_KEY` | Autenticação com Groq |
| `ELEVENLABS_API_KEY` | Autenticação com ElevenLabs |
| `ELEVENLABS_VOICE_ID` | ID da voz selecionada |
| `TOGETHER_API_KEY` | Autenticação com Together AI |
| `QDRANT_URL` | URL da instância Qdrant |
| `QDRANT_API_KEY` | Chave de API do Qdrant |
