# Reels

**Premium iOS video downloader** — paste a link from YouTube, TikTok, Instagram, Twitter/X, or any platform, pick your quality, and download straight to your Camera Roll.

Built with Flutter (iOS) + Python FastAPI backend.

---

## Architecture

```
reels/              ← Flutter iOS app
reels_backend/      ← Python FastAPI backend (yt-dlp)
.github/workflows/  ← CI/CD: builds unsigned IPA on macOS
```

| Layer | Tech |
|-------|------|
| Frontend | Flutter 3.19.0 · Cupertino-only · Dark mode |
| State | Lightweight Cubit (ChangeNotifier) |
| Backend | FastAPI · yt-dlp · uvicorn |
| CI/CD | GitHub Actions · macos-latest |

---

## Quick Start

### 1. Run the Python Backend

```bash
cd reels_backend

# Create virtual environment
python -m venv venv
source venv/bin/activate        # macOS/Linux
# venv\Scripts\activate         # Windows

# Install dependencies
pip install fastapi uvicorn yt-dlp python-multipart aiofiles

# Start server
python main.py
```

The backend runs on **http://localhost:8888**.

> **Note:** You need `ffmpeg` installed on your system for yt-dlp to merge video+audio formats.
> - macOS: `brew install ffmpeg`
> - Windows: Download from [ffmpeg.org](https://ffmpeg.org/download.html) and add to PATH

### 2. Run the Flutter App (iOS Simulator)

```bash
cd reels
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

## Building the IPA

### Option A: GitHub Actions (Recommended)

The project includes a GitHub Actions workflow that builds an unsigned IPA on macOS automatically.

**Triggering a build:**

1. **On push** — Every push to `main` triggers a build automatically
2. **Manual** — Go to **Actions** → **iOS Build** → **Run workflow** → Click **Run workflow**

**Downloading the IPA:**

1. Go to the **Actions** tab in your GitHub repo
2. Click the latest **iOS Build** run
3. Scroll to **Artifacts**
4. Download **Reels-IPA** (zip file containing `Reels.ipa`)

### Option B: Local Build (requires macOS)

```bash
cd reels
flutter build ios --release --no-codesign

# Package the IPA
mkdir Payload
cp -r build/ios/iphoneos/Runner.app Payload/
zip -r Reels.ipa Payload/
```

---

## Installing the IPA with Sideloadly

The IPA is **unsigned** — you cannot install it directly. Use [Sideloadly](https://sideloadly.io/) to sign and install it on your device.

### Steps:

1. Download and install [Sideloadly](https://sideloadly.io/) (Windows or macOS)
2. Connect your iPhone to your computer via USB
3. Open Sideloadly
4. Drag and drop `Reels.ipa` into Sideloadly
5. Enter your Apple ID (a free Apple ID works)
6. Click **Start**
7. If prompted, enter your Apple ID password
8. Wait for the signing and installation to complete

### After installation:

1. On your iPhone, go to **Settings → General → VPN & Device Management**
2. Tap your Apple ID under "Developer App"
3. Tap **Trust** to allow the app to run
4. Open Reels from your home screen

> **Free Apple ID limitation:** Apps signed with a free Apple ID expire after **7 days**. You'll need to re-sideload weekly. A paid Apple Developer account ($99/yr) extends this to 1 year.

---

## Project Structure

```
reels/lib/
├── core/
│   ├── theme/app_theme.dart       # iOS design system (colors, typography, spacing)
│   ├── constants/api_constants.dart
│   └── utils/cubit.dart           # Lightweight state management
├── features/
│   ├── downloader/
│   │   ├── cubit/                 # DownloaderCubit + sealed states
│   │   ├── models/                # VideoInfo, VideoFormat
│   │   ├── screens/               # HomeScreen, QualityPickerScreen
│   │   └── services/              # ApiService (Dio)
│   └── library/
│       └── screens/               # LibraryScreen
├── shared/
│   └── widgets/                   # Pressable, IosButton, IosTextField,
│                                  # QualityCard, DownloadProgressCard,
│                                  # VideoThumbnailCard
└── main.dart                      # App entry, DI, tab scaffold
```

---

## License

Private project. All rights reserved.
