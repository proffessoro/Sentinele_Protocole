# Sentinel Protocol

A proactive inventory risk mitigation agent built with Hub-and-Spoke architecture using the Model Context Protocol (MCP).

## Overview

Sentinel Protocol moves beyond reactive stockout alerts to **anticipate and alert on foreseeable disruptions**. The agent automatically analyzes inventory data, monitors external risk factors (weather, geopolitics, logistics), and provides actionable risk assessments.

## Architecture

### Hub-and-Spoke Design

- **Brain**: LangGraph (Python) - MCP Client orchestrator
- **Spokes**: MCP Servers for data access
  - **PostgreSQL**: Structured inventory data via `@modelcontextprotocol/server-postgres`
  - **Qdrant**: Unstructured data (news, emails, contracts) via `mcp-server-qdrant`

### Specialist Agents

1. **SQL_Analyst**: Queries PostgreSQL for low-coverage, high-risk items
2. **Intel_Officer**: Searches vector store for external context (logistics risks, weather, geopolitical events)
3. **Supply_Commander**: Synthesizes data streams to form decisions and assign risk ratings (CRITICAL/HIGH/LOW)

### Workflow

```
Daily Trigger → SQL_Analyst → Intel_Officer → Supply_Commander → Alert/Action
```

## Prerequisites

- **Docker Desktop**: Running and accessible
- **Python**: 3.10 or higher
- **Node.js**: For `npx` command
- **uv**: Python package installer (`pip install uv` or download from [astral.sh](https://astral.sh))
- **OpenAI API Key**: For LLM inference (set as `OPENAI_API_KEY` environment variable)

## Installation

### 1. Clone/Navigate to Project

```bash
cd Sentinel_Protocol
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 3. Start Infrastructure

```bash
docker compose up -d
```

This will start:
- PostgreSQL on `localhost:5432`
- Qdrant on `localhost:6333`

### 4. Initialize Database

```bash
cat init_db.sql | docker exec -i sentinel_postgres psql -U user -d erp_db
```

**Windows PowerShell alternative:**
```powershell
Get-Content init_db.sql | docker exec -i sentinel_postgres psql -U user -d erp_db
```

### 5. Set OpenAI API Key

**Linux/Mac:**
```bash
export OPENAI_API_KEY="your-api-key-here"
```

**Windows PowerShell:**
```powershell
$env:OPENAI_API_KEY="your-api-key-here"
```

## Usage

### Run the Agent

```bash
python agent.py
```

The agent will:
1. Connect to MCP servers (Postgres and Qdrant)
2. Query inventory for items with < 4 weeks coverage
3. Search for external risk factors
4. Synthesize information and output a risk assessment

### Expected Output

```
Starting Agent Workflow...
--- SQL Analyst ---
Finished node: sql_analyst
Output: {'inventory_risks': ['Microchip X']}
----
--- Intel Officer ---
Finished node: intel_officer
Output: {'external_risks': ['Typhoon signal 10 near Shenzhen (Supplier for Microchip X)']}
----
--- Supply Commander ---
Finished node: supply_commander
Output: {'final_decision': 'CRITICAL RISK: Expedite orders for Microchip X...'}
----
```

## Project Structure

```
Sentinel_Protocol/
├── agent.py              # Main agent implementation (LangGraph)
├── docker-compose.yml    # Infrastructure definition
├── init_db.sql          # Database schema and seed data
├── requirements.txt      # Python dependencies
└── README.md            # This file
```

## Database Schema

### `inventory` Table

| Column | Type | Description |
|--------|------|-------------|
| `product_id` | VARCHAR(50) | Primary key |
| `product_name` | VARCHAR(100) | Product name |
| `stock_level` | INT | Current stock quantity |
| `weekly_usage` | INT | Weekly consumption rate |
| `weeks_cover` | COMPUTED | Auto-calculated coverage in weeks |

### `agent_feedback` Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | SERIAL | Primary key |
| `entity` | VARCHAR(100) | Event/entity type (e.g., "Typhoon") |
| `rule` | VARCHAR(100) | Rule identifier |
| `status` | VARCHAR(50) | Feedback status (e.g., "ignore_if_missed") |
| `created_at` | TIMESTAMP | Timestamp |

## Configuration

### PostgreSQL Connection

Edit `agent.py` line 21 to customize:
```python
"postgresql://user:password@localhost:5432/erp_db"
```

### Qdrant Connection

Edit `agent.py` line 27 to customize:
```python
"--qdrant-url", "http://localhost:6333"
```

### LLM Model

Edit `agent.py` line 32 to change the model:
```python
llm = ChatOpenAI(model="gpt-4o", temperature=0)
```

## Scheduling (Production)

For production use, schedule the agent to run daily using:

**Linux/Mac (cron):**
```bash
0 9 * * * cd /path/to/Sentinel_Protocol && /usr/bin/python agent.py
```

**Windows (Task Scheduler):**
Create a task to run `python agent.py` at your preferred time.

## Troubleshooting

### Docker Connection Issues

**Error**: `error during connect: ... cannot find the file specified`

**Solution**: Ensure Docker Desktop is running. Restart Docker and try again.

### `uv` Not Found

**Error**: `uv: The term 'uv' is not recognized...`

**Solution**: 
```bash
pip install uv
```

### PostgreSQL Connection Refused

**Solution**: Check if container is running:
```bash
docker ps | grep sentinel_postgres
```

If not running, restart:
```bash
docker compose restart postgres
```

### MCP Server Fails to Start

**Solution**: Ensure Node.js and npx are installed:
```bash
npx --version
```

## Self-Improvement Mechanism

The agent includes a "Rule Patching" system via the `agent_feedback` table. When a human operator corrects the agent (e.g., "This typhoon missed, ignore it"), the system writes feedback to the database. On subsequent runs, the agent checks this table and adjusts its reasoning via context injection.

**Future Enhancement**: Implement feedback loop in `supply_commander` function to query `agent_feedback` before making final decisions.

## License

MIT License

## Contributing

This is a demonstration project following Google ADK best practices for Hub-and-Spoke architecture with MCP.
