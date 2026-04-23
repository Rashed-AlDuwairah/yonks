# Reels Backend

FastAPI video downloader API powered by **yt-dlp**.  
Serves the Reels iOS app with video metadata extraction and streaming downloads.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | API + yt-dlp version check |
| `GET` | `/info?url={url}` | Extract video metadata & available formats |
| `GET` | `/download?url={url}&format_id={id}` | Stream the video file to client |

## Quick Start (Local)

### 1. Prerequisites
- Python 3.11+
- ffmpeg (optional — needed for format merging on some sites)

```bash
# macOS
brew install python ffmpeg

# Windows (via winget)
winget install Python.Python.3.12
winget install Gyan.FFmpeg
```

### 2. Install & Run

```bash
cd reels_backend

# Create virtual environment
python -m venv .venv

# Activate
# macOS / Linux:
source .venv/bin/activate
# Windows:
.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python main.py
```

The API starts at **http://localhost:8888**

### 3. Quick Test

```bash
# Health check
curl http://localhost:8888/health

# Get video info
curl "http://localhost:8888/info?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Download a video (replace FORMAT_ID with one from /info response)
curl -o video.mp4 "http://localhost:8888/download?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ&format_id=18"
```

## Docker

```bash
# Build
docker build -t reels-backend .

# Run
docker run -d -p 8888:8888 --name reels-backend reels-backend

# Logs
docker logs -f reels-backend
```

## Production (VPS)

```bash
# Pull & run with restart policy
docker run -d \
  -p 8888:8888 \
  --restart unless-stopped \
  --name reels-backend \
  reels-backend

# Or use docker-compose (create your own docker-compose.yml)
```

### Recommended production hardening:
- Set `allow_origins` in CORS to your app's origin instead of `"*"`
- Add rate limiting (e.g. via nginx reverse proxy)
- Mount a volume for temp downloads if disk space is limited
- Add API key authentication if exposed publicly

## Error Codes

| Code | HTTP | Description |
|------|------|-------------|
| `INVALID_URL` | 400 | URL is malformed or empty |
| `UNSUPPORTED_PLATFORM` | 400 | yt-dlp cannot handle this site |
| `PRIVATE_VIDEO` | 403 | Video requires login or is private |
| `GEO_RESTRICTED` | 403 | Video blocked in server's region |
| `DOWNLOAD_FAILED` | 500 | Generic extraction/download failure |
| `SERVER_ERROR` | 500 | Unexpected server error |

All errors return:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": "Technical details (optional)"
  }
}
```

## Supported Platforms

YouTube, Twitter/X, TikTok, Instagram, Facebook, Reddit, Vimeo,
Dailymotion, Twitch, Pinterest, Snapchat, Bilibili, LinkedIn,
and [1000+ more via yt-dlp](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).
