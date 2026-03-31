# Use an appropriate base image
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Install the project into `/app`
WORKDIR /app

# Set environment variables (e.g., set Python to run in unbuffered mode)
ENV PYTHONUNBUFFERED 1

# Install system dependencies for building libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy the dependency management files (lock file and pyproject.toml) first
COPY uv.lock pyproject.toml README.md langgraph.json /app/

# Install the application dependencies
RUN uv sync --frozen --no-cache

# Copy your application code into the container
COPY src/ /app/

# Set the virtual environment environment variables
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

# Install the package in editable mode
RUN uv pip install -e .

# Install langgraph-cli[inmem] as an isolated tool to avoid uvicorn version
# conflict with chainlit. A .pth file makes the project's packages visible to
# the tool's Python (after the tool's own packages, so newer langgraph_sdk etc.
# from the tool take precedence while project-only deps like pydantic_settings
# are still found).
RUN uv tool install "langgraph-cli[inmem]" --python 3.12 && \
    echo "/app/.venv/lib/python3.12/site-packages" > \
    /root/.local/share/uv/tools/langgraph-cli/lib/python3.12/site-packages/project_deps.pth
ENV PATH="/root/.local/bin:$PATH"

# Define volumes
VOLUME ["/app/data"]

# Expose the port
EXPOSE 8080

# Run the FastAPI app using uvicorn
CMD ["/app/.venv/bin/fastapi", "run", "ai_companion/interfaces/whatsapp/webhook_endpoint.py", "--port", "8080", "--host", "0.0.0.0"]
