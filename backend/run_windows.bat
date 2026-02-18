@echo off
echo Starting NoteShare Backend Setup for Windows...

cd /d "%~dp0"

if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate

echo Installing dependencies...
pip install -r requirements_windows.txt

echo Running migrations...
python manage.py migrate

if not exist db.sqlite3 (
    echo Creating sample data...
    python seed_data.py
)

echo Starting server...
echo Access the API at http://127.0.0.1:8000/
python manage.py runserver 0.0.0.0:8000

pause
