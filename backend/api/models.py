from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.conf import settings


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Custom User model for students"""
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150, unique=True, blank=True, null=True)
    full_name = models.CharField(max_length=255)
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
    bio = models.TextField(blank=True, null=True)
    college = models.CharField(max_length=255, blank=True, null=True)
    course = models.CharField(max_length=255, blank=True, null=True)
    year = models.CharField(max_length=50, blank=True, null=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']

    def __str__(self):
        return self.email


class Subject(models.Model):
    """Subject/Category for notes"""
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    icon = models.CharField(max_length=50, default='book')
    color = models.CharField(max_length=7, default='#6366F1')  # Hex color
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class Note(models.Model):
    """Notes uploaded by students"""
    title = models.CharField(max_length=255)
    description = models.TextField()
    file = models.FileField(upload_to='notes/')
    thumbnail = models.ImageField(upload_to='thumbnails/', null=True, blank=True)
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='notes')
    uploaded_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='uploaded_notes')
    downloads_count = models.PositiveIntegerField(default=0)
    views_count = models.PositiveIntegerField(default=0)
    is_approved = models.BooleanField(default=True)  # Auto-approve since no admin
    tags = models.CharField(max_length=500, blank=True, null=True)  # Comma separated
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title


class NoteRequest(models.Model):
    """Requests posted by students for specific notes"""
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('fulfilled', 'Fulfilled'),
        ('closed', 'Closed'),
    ]
    
    title = models.CharField(max_length=255)
    description = models.TextField()
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='requests', null=True, blank=True)
    requested_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='note_requests')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    fulfilled_by = models.ForeignKey(Note, on_delete=models.SET_NULL, null=True, blank=True, related_name='fulfilled_requests')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title


class Comment(models.Model):
    """Comments on notes or requests - can include file attachments"""
    CONTENT_TYPE_CHOICES = [
        ('note', 'Note'),
        ('request', 'Request'),
    ]
    
    content_type = models.CharField(max_length=20, choices=CONTENT_TYPE_CHOICES)
    note = models.ForeignKey(Note, on_delete=models.CASCADE, related_name='comments', null=True, blank=True)
    request = models.ForeignKey(NoteRequest, on_delete=models.CASCADE, related_name='comments', null=True, blank=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='comments')
    text = models.TextField()
    attachment = models.FileField(upload_to='comment_attachments/', null=True, blank=True)  # For sharing notes in comments
    parent = models.ForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='replies')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Comment by {self.user.email}"


class Download(models.Model):
    """Track note downloads"""
    note = models.ForeignKey(Note, on_delete=models.CASCADE, related_name='download_records')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='downloads')
    downloaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['note', 'user']


class Bookmark(models.Model):
    """Bookmarked notes by users"""
    note = models.ForeignKey(Note, on_delete=models.CASCADE, related_name='bookmarks')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='bookmarked_notes')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['note', 'user']


class Notification(models.Model):
    """User notifications"""
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=255)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.user.email}"