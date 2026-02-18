# Running NoteShare on Windows 🪟

This guide will help you set up and run the NoteShare project on a Windows machine.

## Prerequisites

1.  **Python 3.10+**: Download from [python.org](https://www.python.org/downloads/). Ensure you check "Add Python to PATH" during installation.
2.  **Flutter SDK**: Follow the instructions at [flutter.dev](https://docs.flutter.dev/get-started/install/windows).
3.  **Android Studio** (recommended for mobile emulation) or **Visual Studio** (for Windows desktop app).

---

## 🚀 Backend Setup (One-Click)

The original `requirements.txt` contained Linux-specific packages that won't work on Windows. I have created a Windows-compatible setup script for you.

1.  Navigate to the `backend` folder.
2.  Double-click `run_windows.bat`.
3.  This script will automatically:
    *   Create a virtual environment (`venv`).
    *   Install the correct Windows dependencies.
    *   Run database migrations.
    *   Seed the database with sample data (if needed).
    *   Start the server at `http://127.0.0.1:8000/`.

**Manual Backend Setup (if script fails):**
```powershell
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements_windows.txt
python manage.py migrate
python seed_data.py
python manage.py runserver 0.0.0.0:8000
```

---

## 📱 Frontend Setup

1.  Open a new terminal (Command Prompt or PowerShell).
2.  Navigate to the frontend directory:
    ```powershell
    cd frontend\notesharing_app
    ```
3.  Install dependencies:
    ```powershell
    flutter pub get
    ```
4.  **Important:** Update the API URL in `lib/services/api_service.dart`:
    *   If using **Android Emulator**, use `http://10.0.2.2:8000/api`
    *   If using **Windows Desktop App**, use `http://127.0.0.1:8000/api`
    *   If using a **Physical Device**, use your PC's IP address (e.g., `http://192.168.1.5:8000/api`).

5.  Run the app:
    *   For Android Emulator: `flutter run`
    *   For Windows Desktop: `flutter run -d windows` (Requires Visual Studio C++ build tools)

---

## ⚠️ Common Issues

*   **'uvloop' or 'fcntl' errors**: If you try to use the original `requirements.txt`, you will see these errors because they are Linux-only. Use `requirements_windows.txt` instead.
*   **Execution Policy Error**: If PowerShell blocks the script, run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` in PowerShell as Administrator.
