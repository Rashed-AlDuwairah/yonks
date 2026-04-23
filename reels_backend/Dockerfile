FROM python:3.12-slim

# ── System deps (ffmpeg is required by yt-dlp for format merging) ─────────
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ── Python deps (cached layer) ────────────────────────────────────────────
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Application ───────────────────────────────────────────────────────────
COPY . .

EXPOSE 8888

# Production: no --reload, 2 workers
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8888", "--workers", "2"]
