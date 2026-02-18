from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Subject, Note, NoteRequest, Comment, Download, Bookmark


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['email', 'username', 'full_name', 'college', 'is_active']
    list_filter = ['is_active', 'college', 'course']
    search_fields = ['email', 'username', 'full_name']
    ordering = ['-date_joined']
    
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Profile Info', {'fields': ('full_name', 'profile_picture', 'bio', 'college', 'course', 'year')}),
    )


@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
    list_display = ['name', 'description', 'icon', 'color', 'created_at']
    search_fields = ['name']


@admin.register(Note)
class NoteAdmin(admin.ModelAdmin):
    list_display = ['title', 'subject', 'uploaded_by', 'downloads_count', 'views_count', 'is_approved', 'created_at']
    list_filter = ['subject', 'is_approved', 'created_at']
    search_fields = ['title', 'description', 'tags']
    readonly_fields = ['downloads_count', 'views_count']


@admin.register(NoteRequest)
class NoteRequestAdmin(admin.ModelAdmin):
    list_display = ['title', 'subject', 'requested_by', 'status', 'created_at']
    list_filter = ['status', 'subject', 'created_at']
    search_fields = ['title', 'description']


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ['user', 'content_type', 'text', 'created_at']
    list_filter = ['content_type', 'created_at']
    search_fields = ['text']


@admin.register(Download)
class DownloadAdmin(admin.ModelAdmin):
    list_display = ['note', 'user', 'downloaded_at']
    list_filter = ['downloaded_at']


@admin.register(Bookmark)
class BookmarkAdmin(admin.ModelAdmin):
    list_display = ['note', 'user', 'created_at']
    list_filter = ['created_at']
