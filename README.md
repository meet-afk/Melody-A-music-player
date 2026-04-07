# 🎵 Melody

A beautiful, full-stack, cross-platform music streaming application. **Melody** features a fluid, Spotify-inspired UI, seamless audio playback, and a robust Python backend.

---

## ✨ Features

- 🎧 **Gapless Playback**  
  Smooth, uninterrupted audio streaming with support for skipping and seeking using `just_audio`.

- 🎨 **Dynamic UI Gradients**  
  Automatically extracts colors from album art and applies adaptive background gradients.

- ⚡ **Optimistic UI Updates**  
  Instant visual feedback when liking or unliking songs (no waiting for server response).

- 🕘 **Recently Played History**  
  Fast, locally cached listening history using Hive storage.

- ☁️ **Cloud Media Hosting**  
  Secure upload and retrieval of audio files and thumbnails via Cloudinary.

- 👤 **Custom Profiles**  
  User authentication with on-device profile image selection.

- 📜 **Persistent Queues**  
  Context-aware song queues based on playlists or browsing sections.

---

## 🛠️ Tech Stack

### 📱 Frontend (Mobile App)
- **Framework:** Flutter  
- **State Management:** Riverpod (AutoDispose & KeepAlive)  
- **Audio Engine:** just_audio  
- **Local Storage:** Hive, SharedPreferences  

### ⚙️ Backend (REST API)
- **Framework:** FastAPI (Python)  
- **Database:** PostgreSQL + SQLAlchemy (ORM)  
- **Media Storage:** Cloudinary  
- **Authentication:** JWT (JSON Web Tokens)  

---

## 📸 Screenshots

| Home Feed | Active Player | Profile |
|----------|--------------|--------|
| <img src="https://github.com/meet-afk/Melody-A-music-player/blob/main/client/assets/screenshots/home_page.jpg?raw=true" width="200"/> | <img src="https://github.com/meet-afk/Melody-A-music-player/blob/main/client/assets/screenshots/music_player.jpg?raw=true" width="200"/> | <img src="https://github.com/meet-afk/Melody-A-music-player/blob/main/client/assets/screenshots/profile.jpg?raw=true" width="200"/> |

---

## 🚀 Installation & Setup

### ✅ Prerequisites
- Flutter SDK installed  
- Python 3.8+ installed  
- PostgreSQL database  
- Cloudinary account  

---

## 🔧 Backend Setup (FastAPI)

```bash
cd server
```

### 1. Create Virtual Environment
```bash
python -m venv venv
```

### 2. Activate Environment

**Windows**
```bash
venv\Scripts\activate
```

**Mac/Linux**
```bash
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Create `.env` File

```env
DATABASE_URL=your_postgresql_url
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
JWT_SECRET=your_jwt_secret
```

### 5. Run Server
```bash
uvicorn main:app --reload
```

---

## 📱 Frontend Setup (Flutter)

```bash
cd client
```

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Code Generation (Riverpod)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
```bash
flutter run
```

---

## 📌 Future Improvements

- 🎶 Playlist sharing  
- 🌐 Web version  
- 🤖 AI-based music recommendations  
- 📊 Listening analytics dashboard  

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork the repo and submit a pull request.

---

## 📄 License

This project is licensed under the MIT License.

---

## 💙 Acknowledgements

Inspired by Spotify UI/UX and modern music streaming apps.