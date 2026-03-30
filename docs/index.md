# Índice de Documentação do Projeto

> Atualizado em: 2026-03-30

## Ava — Agente WhatsApp com IA Conversacional

### Referência Rápida

- **Stack:** Python 3.12 · FastAPI · LangGraph · Chainlit · Groq · Qdrant
- **Entry Points:** WhatsApp webhook (`:8080`) / Chainlit UI (`:8000`)
- **Arquitetura:** Agent-based com StateGraph, 8 nós, 3 workflows
- **Serviços Externos:** Groq (LLM/STT/Vision) · ElevenLabs (TTS) · Together AI (Image) · Qdrant (Vector DB)

---

## Documentação Técnica Gerada

- **[project-overview.md](./project-overview.md)** - Resumo executivo, capacidades e stack tecnológico
- **[architecture.md](./architecture.md)** - Design do sistema, fluxo de processamento e decisões arquiteturais
- **[source-tree-analysis.md](./source-tree-analysis.md)** - Estrutura de diretórios anotada e entry points
- **[api-contracts.md](./api-contracts.md)** - Endpoints REST e APIs externas consumidas
- **[data-models.md](./data-models.md)** - Pydantic models, dataclasses, armazenamento vetorial e SQLite
- **[development-guide.md](./development-guide.md)** - Setup local, dependências e workflow de desenvolvimento
- **[deployment-guide.md](./deployment-guide.md)** - Docker Compose local e Google Cloud Run

## Documentação Original do Projeto

- **[GETTING_STARTED.md](./GETTING_STARTED.md)** - Guia de início rápido com setup de API keys
- **[gcp_setup.md](./gcp_setup.md)** - Instruções passo a passo de deploy no Google Cloud Platform

## Documentação Raiz

- **[README.md](../README.md)** - Documentação principal do curso com syllabus e links para lições

## Metadados

- **[project-scan-report.json](./project-scan-report.json)** - Relatório JSON do scan automatizado do projeto

---

## Avaliação de Completude para Desenvolvimento Assistido por IA

### Cobertura Atual: O que os documentos permitem

| Dimensão | Documento | Cobertura | Nota |
|----------|-----------|-----------|------|
| **Entender o sistema** | architecture.md | ✅ Completa | Fluxo, nós, edges, padrões e decisões documentados |
| **Navegar o código** | source-tree-analysis.md | ✅ Completa | 23 arquivos Python mapeados com responsabilidades |
| **Estender o grafo** | development-guide.md | ✅ Completa | 7 passos documentados para adicionar nova capacidade |
| **Entender os dados** | data-models.md | ✅ Completa | 7 modelos documentados campo a campo |
| **Integrar com APIs** | api-contracts.md | ✅ Completa | Endpoints, payloads e SDKs mapeados |
| **Configurar ambiente** | development-guide.md + GETTING_STARTED.md | ✅ Completa | Setup, env vars, Docker, troubleshooting |
| **Fazer deploy** | deployment-guide.md + gcp_setup.md | ✅ Completa | Docker Compose + Cloud Run |
| **Saber o quê construir** | — | ❌ Ausente | Sem PRD, sem visão de produto para evolução |
| **Ter escopo de trabalho** | — | ❌ Ausente | Sem epics, stories ou backlog |
| **Seguir convenções** | — | ⚠️ Parcial | Ruff config existe; sem regras de projeto para agentes |
| **Validar implementação** | — | ❌ Ausente | Zero testes automatizados; sem estratégia de testes |
| **Priorizar tarefas** | — | ❌ Ausente | Sem sprint plan ou sequência de implementação |

### Diagnóstico por Camada

#### 1. Camada de Produto (❌ Ausente)

Não existe **PRD**, **Product Brief** nem qualquer documento de requisitos. Um agente de IA tem contexto técnico suficiente para entender *como* o sistema funciona, mas não tem orientação sobre:

- Qual é a visão de evolução do produto
- Quais features são desejadas e por quê
- Quais restrições de negócio existem
- Quais personas/usuários devem ser atendidos

**Impacto:** O agente não consegue propor nem implementar features por conta própria — precisa que cada pedido seja descrito do zero a cada interação.

#### 2. Camada de Planejamento (❌ Ausente)

Não existem **Epics**, **User Stories** nem **Sprint Plan**. Sem eles:

- Não há unidades de trabalho definidas para o agente executar
- Não há critérios de aceite para validar implementações
- Não há sequência ou dependências entre features

**Impacto:** O agente não pode operar no modo "dev this story" — não há stories para implementar.

#### 3. Camada de Convenções (⚠️ Parcial)

O projeto tem Ruff configurado (line-length 120, regras E/F/W/Q/I) e pre-commit hooks, mas:

- Não existem `.cursor/rules/` com convenções de projeto
- Não há padrão documentado de error handling (algumas funções usam `try/except` genérico, outras propagam)
- Inconsistência de logging: `whatsapp_response.py` usa `print()` para debug e `logger` para erros; `memory_manager.py` usa apenas `logger`
- Não há padrão documentado para criação de novos módulos (naming, structure, exports)

**Impacto:** O agente pode gerar código funcional mas estilisticamente inconsistente com o existente.

#### 4. Camada de Testes (❌ Ausente)

O projeto **não possui nenhum teste automatizado** — nem unitário, nem de integração, nem e2e. Não há:

- Framework de testes configurado (pytest, etc.)
- Diretório `tests/`
- Fixtures ou mocks para os serviços externos
- CI pipeline com quality gates

**Impacto:** Features implementadas por agentes não terão validação automatizada. Regressões passarão despercebidas.

### Documentos Recomendados (Ordem de Prioridade)

| # | Documento | Skill BMad | Comando |
|---|-----------|------------|---------|
| 1 | **PRD** | bmad-create-prd | "lets create a product requirements document" |
| 2 | **Epics e Stories** | bmad-create-epics-and-stories | "create the epics and stories list" |
| 3 | **Project Context** | bmad-generate-project-context | "generate project context" |
| 4 | **Sprint Plan** | bmad-sprint-planning | "run sprint planning" |
| 5 | **Story detalhada** | bmad-create-story | "create story [id]" |
| 6 | **Estratégia de testes** | bmad-testarch-test-design | "lets design test plan" |

### Conclusão

A documentação técnica está **completa e precisa** para entender o sistema existente. Porém, para desenvolvimento assistido por IA de **novas features**, faltam os artefatos de produto e planejamento (PRD → Epics → Stories → Sprint Plan) que dão ao agente o contexto de *"o quê construir"* e *"em que ordem"*. Sem eles, o agente opera em modo reativo — só executa instruções explícitas do desenvolvedor, sem autonomia para planejar ou sequenciar trabalho.

---

## Como Começar

### Desenvolvimento Local

```bash
# 1. Clonar e instalar
git clone https://github.com/neural-maze/ava-whatsapp-agent-course.git
cd ava-whatsapp-agent-course
uv venv .venv && source .venv/bin/activate && uv pip install -e .

# 2. Configurar variáveis de ambiente
cp .env.example .env

# 3. Executar
make ava-run
```

### Para Desenvolver Novas Funcionalidades

1. Consultar [Arquitetura](./architecture.md) para entender o fluxo
2. Seguir o [Guia de Desenvolvimento](./development-guide.md) para setup e padrões
3. Revisar [Modelos de Dados](./data-models.md) para entender o estado do grafo
4. Verificar [Contratos de API](./api-contracts.md) para integrações externas
