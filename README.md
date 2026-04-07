# 🎵 Melody

A beautiful, full-stack cross-platform music streaming application. Melody features a fluid, Spotify-inspired user interface, seamless audio playback, and a robust Python backend. 

## ✨ Features

* **Gapless Playback:** Smooth, uninterrupted audio streaming, skipping, and seeking powered by `just_audio`.
* **Dynamic UI Gradients:** The app visually adapts to the music, extracting hex colors from album art to paint the background gradients.
* **Optimistic UI Updates:** Instant, zero-lag visual feedback when liking or unliking songs.
* **Recently Played History:** Fast, locally-cached listening history utilizing Hive storage.
* **Cloud Media Hosting:** Secure and fast upload/retrieval of audio files and thumbnails via Cloudinary.
* **Custom Profiles:** On-device profile image picking and user authentication.
* **Persistent Queues:** Contextual song queues based on the playlist or library section you are currently browsing.

## 🛠️ Tech Stack

**Frontend (Mobile App)**
* **Framework:** [Flutter](https://flutter.dev/)
* **State Management:** [Riverpod](https://riverpod.dev/) (Auto-Dispose & Keep-Alive architectures)
* **Audio Engine:** `just_audio`
* **Local Storage:** Hive & Shared Preferences

**Backend (REST API)**
* **Framework:** [FastAPI](https://fastapi.tiangolo.com/) (Python)
* **Database:** PostgreSQL with SQLAlchemy (ORM)
* **Media Storage:** Cloudinary
* **Authentication:** JWT (JSON Web Tokens)

---

## 📸 Screenshots
| Home Feed | Active Player | Profile |
| :---: | :---: | :---: |
| <img src="https://github.com/meet-afk/Melody-A-music-player/blob/main/client/assets/screenshots/home_page.jpg?raw=true" width="200"/> | <img src="https://github.com/meet-afk/Melody-A-music-player/blob/main/client/assets/screenshots/music_player.jpg?raw=true" width="200"/> | <img src="https://github.com/meet-afk/Melody-A-music-player/blob/main/client/assets/screenshots/profile.jpg?raw=true" width="200"/> |

---

## 🚀 Installation & Setup

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* [Python 3.8+](https://www.python.org/downloads/) installed.
* A Cloudinary account.
* A PostgreSQL database instance.

### 1. Backend Setup (FastAPI)
1. Navigate to the backend directory:
   ```bash
   cd server

    Create a virtual environment and install dependencies:
    Bash

    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    pip install -r requirements.txt

    Create a .env file in the root of the server directory and add your credentials:
    Code snippet

    DATABASE_URL=your_postgresql_url
    CLOUDINARY_CLOUD_NAME=your_cloud_name
    CLOUDINARY_API_KEY=your_api_key
    API_SECRET=your_api_secret
    JWT_SECRET=your_jwt_secret

    Start the server:
    Bash

    uvicorn main:app --reload

2. Frontend Setup (Flutter)

    Navigate to the client directory:
    Bash

    cd client

    Install dependencies:
    Bash

    flutter pub get

    Run Riverpod code generation (if you make changes to providers):
    Bash

    flutter pub run build_runner build --delete-conflicting-outputs

    Run the app on your emulator or connected device:
    Bash

    flutter run
