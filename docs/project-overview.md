# Visão Geral do Projeto

> Gerado em: 2026-03-30 | Scan Level: exhaustive

## Ava — Agente WhatsApp com IA Conversacional

**Ava** é um agente de IA conversacional multimodal que opera via WhatsApp, simulando uma persona realista inspirada no filme Ex Machina. Desenvolvido como material de curso educacional por [The Neural Maze](https://theneuralmaze.substack.com/), o projeto demonstra como construir um agente de IA production-ready com capacidades de texto, voz e imagem.

---

## Resumo Executivo

| Propriedade | Valor |
|-------------|-------|
| **Nome** | Ava (ai-companion) |
| **Versão** | 0.1.0 |
| **Tipo** | Agente de IA conversacional multimodal |
| **Linguagem** | Python ≥3.12 |
| **Licença** | MIT |
| **Repositório** | Monolith |
| **Tipo de Projeto** | Backend (FastAPI + LangGraph) |

---

## Capacidades

| Capacidade | Tecnologia | Descrição |
|-----------|-----------|-----------|
| **Conversação textual** | Groq (Llama 3.3 70B) | Respostas contextualizadas com persona |
| **Análise de imagem** | Groq (Llama 3.2 Vision 90B) | Compreensão de imagens recebidas |
| **Geração de imagem** | Together AI (FLUX.1-schnell) | Criação de imagens baseadas em conversa |
| **Transcrição de voz** | Groq (Whisper Large v3 Turbo) | Conversão de áudio para texto |
| **Síntese de voz** | ElevenLabs | Conversão de texto para áudio |
| **Memória de longo prazo** | Qdrant + sentence-transformers | Lembrar fatos sobre o usuário |
| **Memória de curto prazo** | SQLite (LangGraph checkpoint) | Persistência de conversa |
| **Persona dinâmica** | Character card + agenda semanal | Simulação de vida cotidiana |

---

## Stack Tecnológico (Resumo)

| Camada | Tecnologias |
|--------|-------------|
| **Orquestração** | LangGraph StateGraph |
| **LLM** | Groq (Llama 3.3, Llama 3.1 8B, Llama 3.2 Vision, Whisper) |
| **Mídia** | ElevenLabs (TTS), Together AI (FLUX) |
| **Armazenamento** | Qdrant (vetorial), SQLite (checkpoints) |
| **Interfaces** | FastAPI (WhatsApp webhook), Chainlit (Web UI) |
| **Infraestrutura** | Docker Compose, Google Cloud Run |
| **Qualidade** | Ruff (linter/formatter), Pre-commit hooks |

---

## Arquitetura (Resumo)

O sistema segue uma arquitetura de **agente com grafo de estado**:

1. **Interfaces** recebem mensagens (WhatsApp ou Chainlit)
2. **Grafo LangGraph** processa a mensagem em 8 nós sequenciais/condicionais
3. **Router** classifica a intenção (conversa, imagem ou áudio)
4. **Módulos especializados** executam a ação correspondente
5. **Resposta** é enviada de volta pela interface de origem

Para detalhes completos, consulte [Arquitetura](./architecture.md).

---

## Estrutura do Repositório

```
ava-whatsapp-agent-course/
├── src/ai_companion/          # Código fonte principal
│   ├── core/                  # Prompts, exceções, schedules
│   ├── graph/                 # Motor do agente (LangGraph)
│   ├── interfaces/            # WhatsApp (FastAPI) + Chainlit
│   └── modules/               # Image, Speech, Memory, Schedules
├── docs/                      # Documentação
├── notebooks/                 # Notebooks experimentais
├── docker-compose.yml         # Orquestração de serviços
├── Dockerfile*                # Imagens Docker (WhatsApp + Chainlit)
├── pyproject.toml             # Dependências e configuração
└── Makefile                   # Comandos de build e desenvolvimento
```

Para a árvore completa, consulte [Análise de Código Fonte](./source-tree-analysis.md).

---

## Links para Documentação Detalhada

- [Arquitetura](./architecture.md) — Design detalhado do sistema
- [Contratos de API](./api-contracts.md) — Endpoints e integrações
- [Modelos de Dados](./data-models.md) — Schemas e persistência
- [Análise de Código Fonte](./source-tree-analysis.md) — Estrutura de diretórios
- [Guia de Desenvolvimento](./development-guide.md) — Setup e workflow de dev
- [Guia de Deploy](./deployment-guide.md) — Docker e Cloud Run

---

## Contexto do Curso

Este projeto é o material prático de um curso de 6 lições:

| Lição | Tema |
|-------|------|
| 1 | Visão geral do projeto e arquitetura |
| 2 | LangGraph e implementação de workflows |
| 3 | Sistema de memória (curto e longo prazo) |
| 4 | Pipeline de voz (STT + TTS) |
| 5 | Processamento e geração de imagens |
| 6 | Integração WhatsApp e deploy no Cloud Run |

**Criadores:** Miguel Otero Pedrido e Jesús Copado (Senior ML/AI Engineers)
