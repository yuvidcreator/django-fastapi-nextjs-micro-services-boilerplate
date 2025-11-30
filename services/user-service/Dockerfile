# Multi-stage Dockerfile (uses UV package manager)
FROM python:3.11-slim as builder

# Install build deps
RUN apt-get update && apt-get install -y build-essential gcc

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /app

# Copy lock / requirements for deterministic builds
COPY pyproject.toml uv.lock requirements.txt /app/

# Use UV to install dependencies into /opt/venv
# NOTE: uv install should create virtualenv; substitute if uv semantics differ
RUN uv venv /opt/venv

# Use the virtual environment automatically
ENV VIRTUAL_ENV=/opt/venv

# Place entry points in the environment at the front of the path
ENV PATH="/opt/venv/bin:$PATH"

# Install packages with uv (fallback to pip install -r)
# Use uv if present; otherwise fall back
RUN if command -v uv >/dev/null 2>&1; then \
        uv install ; \
    else \
        uv pip install -r requirements.txt ; \
    fi

# Copy source
FROM python:3.11-slim as runtime
WORKDIR /app

# Copy venv from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Application code
COPY . /app

# Collect static (if any)
ENV PYTHONUNBUFFERED=1

# Expose port for ASGI
EXPOSE 8001

# Entrypoint — run with Gunicorn + Uvicorn worker for production
CMD ["gunicorn", "user_service.wsgi:application", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8001", "--workers", "3", "--timeout", "120"]
