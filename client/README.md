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
*(Add your screenshots here by dragging and dropping images into the GitHub editor!)*
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