# Use official lightweight Python image
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
# psycopg2 requires gcc and build tools. While the binary version often works without them,
# including them ensures stability and compatibility.
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dependencies and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ... (Previous steps remain unchanged)

# Copy source code
COPY ./app ./app

# Expose port
EXPOSE 8000

CMD ["gunicorn", "app.main:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]