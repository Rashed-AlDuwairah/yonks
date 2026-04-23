"""
Reels Backend — FastAPI video downloader API powered by yt-dlp.

Endpoints:
    GET /health             → API & yt-dlp version check
    GET /info?url={url}     → Extract video metadata + available formats
    GET /download?url={url}&format_id={id} → Stream video file to client
"""

import asyncio
import logging
import os
import re
import shutil
import tempfile
from pathlib import Path
from urllib.parse import urlparse

import aiofiles
import yt_dlp
from fastapi import BackgroundTasks, FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse

# ═══════════════════════════════════════════════════════════════════════════════
#  CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

API_VERSION = "1.0.0"
MAX_FORMATS = 5
CHUNK_SIZE = 1024 * 1024  # 1 MB streaming chunks

# ═══════════════════════════════════════════════════════════════════════════════
#  LOGGING
# ═══════════════════════════════════════════════════════════════════════════════

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("reels")

# ═══════════════════════════════════════════════════════════════════════════════
#  APP
# ═══════════════════════════════════════════════════════════════════════════════

app = FastAPI(
    title="Reels Backend",
    version=API_VERSION,
    description="Video downloader API for the Reels iOS app.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Open for development — restrict in production
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["Content-Length", "Content-Disposition"],
)

# ═══════════════════════════════════════════════════════════════════════════════
#  ERROR SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

# fmt: off
class ErrorCode:
    INVALID_URL          = "INVALID_URL"
    UNSUPPORTED_PLATFORM = "UNSUPPORTED_PLATFORM"
    PRIVATE_VIDEO        = "PRIVATE_VIDEO"
    GEO_RESTRICTED       = "GEO_RESTRICTED"
    DOWNLOAD_FAILED      = "DOWNLOAD_FAILED"
    SERVER_ERROR         = "SERVER_ERROR"
# fmt: on


def error_response(
    code: str,
    message: str,
    details: str | None = None,
    status: int = 400,
) -> JSONResponse:
    """Return a consistent error JSON matching the contract the Flutter app expects."""
    body: dict = {"error": {"code": code, "message": message}}
    if details:
        body["error"]["details"] = details
    log.warning("Error %s [%d]: %s", code, status, message)
    return JSONResponse(status_code=status, content=body)


def _map_ytdlp_error(exc: Exception) -> tuple[str, str, int]:
    """Map yt-dlp exception text to our error code, human message, HTTP status."""
    msg = str(exc).lower()

    if any(kw in msg for kw in ("private", "login", "sign in", "authenticate")):
        return ErrorCode.PRIVATE_VIDEO, "This video is private or requires login.", 403

    if any(kw in msg for kw in ("geo", "not available in your country", "blocked")):
        return ErrorCode.GEO_RESTRICTED, "This video is not available in your region.", 403

    if any(kw in msg for kw in ("unsupported url", "no suitable", "not a valid url")):
        return ErrorCode.UNSUPPORTED_PLATFORM, "This URL is not supported.", 400

    return ErrorCode.DOWNLOAD_FAILED, "Failed to process this video.", 500


# ═══════════════════════════════════════════════════════════════════════════════
#  PLATFORM DETECTION
# ═══════════════════════════════════════════════════════════════════════════════

PLATFORM_DOMAINS: dict[str, list[str]] = {
    "youtube":     ["youtube.com", "youtu.be", "youtube-nocookie.com", "m.youtube.com"],
    "twitter":     ["twitter.com", "x.com", "t.co", "mobile.twitter.com"],
    "tiktok":      ["tiktok.com", "vm.tiktok.com", "m.tiktok.com"],
    "instagram":   ["instagram.com", "instagr.am"],
    "facebook":    ["facebook.com", "fb.watch", "fb.com", "m.facebook.com"],
    "reddit":      ["reddit.com", "v.redd.it", "old.reddit.com"],
    "vimeo":       ["vimeo.com", "player.vimeo.com"],
    "dailymotion": ["dailymotion.com", "dai.ly"],
    "twitch":      ["twitch.tv", "clips.twitch.tv"],
    "pinterest":   ["pinterest.com", "pin.it"],
    "snapchat":    ["snapchat.com", "story.snapchat.com"],
    "bilibili":    ["bilibili.com", "b23.tv"],
    "linkedin":    ["linkedin.com"],
}


def detect_platform(url: str) -> str:
    try:
        domain = urlparse(url).netloc.lower().removeprefix("www.")
        for platform, domains in PLATFORM_DOMAINS.items():
            if domain in domains or any(domain.endswith(f".{d}") for d in domains):
                return platform
    except Exception:
        pass
    return "other"


def _validate_url(url: str) -> bool:
    try:
        r = urlparse(url)
        return r.scheme in ("http", "https") and bool(r.netloc)
    except Exception:
        return False


# ═══════════════════════════════════════════════════════════════════════════════
#  FORMAT HELPERS
# ═══════════════════════════════════════════════════════════════════════════════

_RESOLUTION_LABELS = [
    (2160, "4K"),
    (1440, "1440p"),
    (1080, "1080p"),
    (720,  "720p"),
    (480,  "480p"),
    (360,  "360p"),
    (240,  "240p"),
    (144,  "144p"),
]


def _resolution_label(height: int) -> str:
    for min_h, label in _RESOLUTION_LABELS:
        if height >= min_h:
            return label
    return f"{height}p"


def _filter_formats(raw_formats: list[dict]) -> list[dict]:
    """
    Keep only combined (video + audio) formats.
    Deduplicate by resolution, sort by quality descending, return max 5.
    """
    combined: list[dict] = []

    for f in raw_formats:
        vcodec = f.get("vcodec") or "none"
        acodec = f.get("acodec") or "none"
        if vcodec == "none" or acodec == "none":
            continue

        height = f.get("height") or 0
        if height == 0:
            continue

        combined.append(
            {
                "format_id": str(f.get("format_id", "")),
                "resolution": _resolution_label(height),
                "width": f.get("width") or 0,
                "height": height,
                "ext": f.get("ext", "mp4"),
                "filesize": f.get("filesize") or f.get("filesize_approx") or 0,
                "vcodec": (vcodec.split(".")[0] if "." in vcodec else vcodec),
                "acodec": (acodec.split(".")[0] if "." in acodec else acodec),
                "has_audio": True,
            }
        )

    # Best quality first
    combined.sort(key=lambda x: x["height"], reverse=True)

    # One entry per resolution tier
    seen: set[str] = set()
    unique: list[dict] = []
    for f in combined:
        if f["resolution"] not in seen:
            seen.add(f["resolution"])
            unique.append(f)

    return unique[:MAX_FORMATS]


def _sanitize_filename(title: str, ext: str) -> str:
    clean = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "", title).strip(". ")
    if not clean:
        clean = "video"
    return f"{clean[:200]}.{ext}"


_MIME_TYPES: dict[str, str] = {
    "mp4":  "video/mp4",
    "webm": "video/webm",
    "mkv":  "video/x-matroska",
    "mov":  "video/quicktime",
    "avi":  "video/x-msvideo",
    "flv":  "video/x-flv",
    "3gp":  "video/3gpp",
    "ts":   "video/mp2t",
}


# ═══════════════════════════════════════════════════════════════════════════════
#  ROUTES
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Health ───────────────────────────────────────────────────────────────────

@app.get("/health")
async def health():
    """Check API liveness + versions.  Used by the Flutter app on startup."""
    return {
        "status": "ok",
        "api_version": API_VERSION,
        "yt_dlp_version": yt_dlp.version.__version__,
    }


# ─── Info ─────────────────────────────────────────────────────────────────────

@app.get("/info")
async def get_video_info(url: str = Query(..., description="Video URL to inspect")):
    """
    Extract video metadata and available download formats.

    Returns title, thumbnail, duration, uploader, auto-detected platform,
    and up to 5 quality options (combined video+audio only).
    """

    # 1 — Validate URL
    if not _validate_url(url):
        return error_response(
            ErrorCode.INVALID_URL,
            "Please provide a valid URL.",
            f"Received: {url}",
        )

    platform = detect_platform(url)
    log.info("📡  /info  platform=%s  url=%s", platform, url[:80])

    # 2 — Extract info via yt-dlp (blocking → run in thread)
    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
        "noplaylist": True,
        "socket_timeout": 15,
    }

    try:
        info = await asyncio.to_thread(
            lambda: yt_dlp.YoutubeDL(ydl_opts).extract_info(url, download=False)
        )
    except Exception as exc:
        code, message, status = _map_ytdlp_error(exc)
        return error_response(code, message, str(exc), status)

    if not info:
        return error_response(
            ErrorCode.DOWNLOAD_FAILED,
            "Could not extract video information.",
        )

    # 3 — Filter formats
    raw_formats = info.get("formats") or []
    formats = _filter_formats(raw_formats)

    if not formats:
        return error_response(
            ErrorCode.DOWNLOAD_FAILED,
            "No downloadable formats found for this video.",
            f"Total raw formats: {len(raw_formats)}, none had combined video+audio.",
        )

    # 4 — Build response
    return {
        "title": info.get("title") or "Untitled",
        "thumbnail": info.get("thumbnail") or "",
        "duration": info.get("duration") or 0,
        "uploader": info.get("uploader") or info.get("channel") or "Unknown",
        "platform": platform,
        "formats": formats,
    }


# ─── Download ─────────────────────────────────────────────────────────────────

@app.get("/download")
async def download_video(
    background_tasks: BackgroundTasks,
    url: str = Query(..., description="Video URL"),
    format_id: str = Query(..., description="Target format ID from /info"),
):
    """
    Download the selected format and stream it back to the client.

    The file is downloaded to a temp directory, streamed via chunked response,
    and the temp directory is cleaned up automatically after the response completes.
    """

    # 1 — Validate
    if not _validate_url(url):
        return error_response(ErrorCode.INVALID_URL, "Please provide a valid URL.")

    log.info("⬇️   /download  format=%s  url=%s", format_id, url[:80])

    # 2 — Download to temp dir
    temp_dir = tempfile.mkdtemp(prefix="reels_")
    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
        "noplaylist": True,
        "format": format_id,
        "outtmpl": os.path.join(temp_dir, "%(title).200s.%(ext)s"),
        "socket_timeout": 30,
    }

    try:
        info = await asyncio.to_thread(
            lambda: yt_dlp.YoutubeDL(ydl_opts).extract_info(url, download=True)
        )
    except Exception as exc:
        shutil.rmtree(temp_dir, ignore_errors=True)
        code, message, status = _map_ytdlp_error(exc)
        return error_response(code, message, str(exc), status)

    # 3 — Locate the downloaded file
    downloaded = [
        f
        for f in Path(temp_dir).iterdir()
        if f.is_file() and not f.name.endswith(".part") and not f.name.endswith(".ytdl")
    ]

    if not downloaded:
        shutil.rmtree(temp_dir, ignore_errors=True)
        return error_response(
            ErrorCode.DOWNLOAD_FAILED,
            "Download completed but no file was produced.",
        )

    file_path = downloaded[0]
    file_size = file_path.stat().st_size
    ext = file_path.suffix.lstrip(".")
    title = (info.get("title") or "video") if info else "video"
    filename = _sanitize_filename(title, ext)
    content_type = _MIME_TYPES.get(ext, "application/octet-stream")

    log.info("✅  Downloaded %s  (%s, %.1f MB)", filename, ext, file_size / 1_048_576)

    # 4 — Schedule cleanup AFTER the streaming response finishes
    background_tasks.add_task(shutil.rmtree, temp_dir, True)

    # 5 — Stream via async chunked response
    async def _stream():
        async with aiofiles.open(file_path, "rb") as fh:
            while True:
                chunk = await fh.read(CHUNK_SIZE)
                if not chunk:
                    break
                yield chunk

    return StreamingResponse(
        _stream(),
        media_type=content_type,
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"',
            "Content-Length": str(file_size),
        },
    )


# ═══════════════════════════════════════════════════════════════════════════════
#  ENTRYPOINT
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8888,
        reload=True,
        log_level="info",
    )
