# NoteShare - Student Note Sharing Application

A mobile application that allows students to upload, share, and download notes. Students can also post requests for specific notes and share notes in comments.

## 🚀 Features

- **📤 Upload Notes** - Students can upload their notes (PDF, DOC, PPT, Images)
- **📥 Download Notes** - Download notes shared by other students
- **🔍 Search & Filter** - Search notes by title, description, tags, or filter by subject
- **📝 Request Notes** - Post requests for specific notes you need
- **💬 Comments** - Share notes and respond to requests in comments
- **🔖 Bookmarks** - Save notes for quick access later
- **👤 User Profiles** - Track your uploads, downloads, and activity

## 🛠 Tech Stack

### Backend
- **Framework**: Django 5.x with Django REST Framework
- **Database**: SQLite (development) / PostgreSQL (production)
- **Authentication**: Token-based authentication

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **HTTP Client**: http package
- **Design**: Custom dark theme with modern UI

## 📁 Project Structure

```
Notesharingapp/
├── backend/                    # Django Backend
│   ├── api/                    # Main API app
│   │   ├── models.py          # Database models
│   │   ├── serializers.py     # DRF serializers
│   │   ├── views.py           # API views
│   │   ├── urls.py            # API routes
│   │   └── admin.py           # Admin configuration
│   ├── notesharing/           # Project settings
│   ├── media/                 # Uploaded files
│   ├── manage.py
│   └── seed_data.py           # Sample data script
│
└── frontend/                   # Flutter Frontend
    └── notesharing_app/
        └── lib/
            ├── main.dart              # App entry point
            ├── models/                # Data models
            ├── services/              # API service
            ├── providers/             # State management
            ├── screens/               # UI screens
            ├── widgets/               # Reusable widgets
            └── utils/                 # Theme and utilities
```

## 🚀 Getting Started

### Prerequisites
- Python 3.10+
- Flutter 3.x
- Android Studio / VS Code

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows
```

3. Install dependencies:
```bash
pip install django djangorestframework django-cors-headers Pillow python-dotenv
```

4. Run migrations:
```bash
python manage.py migrate
```

5. Create sample data:
```bash
python seed_data.py
```

6. Start server:
```bash
python manage.py runserver 0.0.0.0:8000
```

### Frontend Setup

1. Navigate to frontend app:
```bash
cd frontend/notesharing_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API URL in `lib/services/api_service.dart`:
```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// For physical device (replace with your IP)
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

4. Run the app:
```bash
flutter run
```

## 📱 API Endpoints

### Authentication
- `POST /api/auth/register/` - Register new user
- `POST /api/auth/login/` - Login user
- `POST /api/auth/logout/` - Logout user
- `GET/PUT /api/auth/profile/` - Get/Update profile

### Notes
- `GET /api/notes/` - List all notes
- `POST /api/notes/` - Upload new note
- `GET /api/notes/{id}/` - Get note details
- `POST /api/notes/{id}/download/` - Download note
- `POST /api/notes/{id}/bookmark/` - Toggle bookmark

### Requests
- `GET /api/requests/` - List note requests
- `POST /api/requests/` - Create note request
- `GET /api/requests/{id}/` - Get request details

### Comments
- `GET /api/comments/` - List comments
- `POST /api/comments/` - Add comment

### User Data
- `GET /api/my/bookmarks/` - User's bookmarks
- `GET /api/my/downloads/` - User's downloads
- `GET /api/dashboard/` - User statistics

## 🎨 Screenshots

The app features a modern dark theme with:
- Gradient backgrounds
- Animated transitions
- Card-based layouts
- Custom bottom navigation
- Subject-based color coding

## 📄 License

This project is for educational purposes.

## 👤 Author

Built as a student note sharing platform.
