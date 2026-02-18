"""
Seed script to populate database with sample data
Run: python manage.py shell < seed_data.py
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'notesharing.settings')
django.setup()

from api.models import Subject

# Create subjects
subjects_data = [
    {'name': 'Mathematics', 'description': 'Algebra, Calculus, Statistics, and more', 'icon': 'calculate', 'color': '#6366F1'},
    {'name': 'Physics', 'description': 'Mechanics, Thermodynamics, Quantum Physics', 'icon': 'science', 'color': '#8B5CF6'},
    {'name': 'Chemistry', 'description': 'Organic, Inorganic, Physical Chemistry', 'icon': 'biotech', 'color': '#EC4899'},
    {'name': 'Biology', 'description': 'Botany, Zoology, Microbiology', 'icon': 'spa', 'color': '#10B981'},
    {'name': 'Computer Science', 'description': 'Programming, Data Structures, Algorithms', 'icon': 'computer', 'color': '#3B82F6'},
    {'name': 'English', 'description': 'Literature, Grammar, Writing', 'icon': 'menu_book', 'color': '#F59E0B'},
    {'name': 'History', 'description': 'World History, Ancient Civilizations', 'icon': 'history_edu', 'color': '#EF4444'},
    {'name': 'Economics', 'description': 'Micro, Macro Economics, Finance', 'icon': 'trending_up', 'color': '#14B8A6'},
    {'name': 'Psychology', 'description': 'Cognitive, Behavioral, Social Psychology', 'icon': 'psychology', 'color': '#A855F7'},
    {'name': 'Engineering', 'description': 'Mechanical, Electrical, Civil Engineering', 'icon': 'engineering', 'color': '#64748B'},
]

for subject_data in subjects_data:
    Subject.objects.get_or_create(
        name=subject_data['name'],
        defaults=subject_data
    )
    print(f"Created subject: {subject_data['name']}")

print("\n✅ Seed data created successfully!")
