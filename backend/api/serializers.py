from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from .models import Subject, Note, NoteRequest, Comment, Download, Bookmark, Notification

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'full_name', 'profile_picture', 
                  'bio', 'college', 'course', 'year', 'created_at']
        read_only_fields = ['id', 'created_at']


class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'username', 'full_name', 'password', 'password_confirm', 
                  'college', 'course', 'year']

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password": "Passwords don't match"})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, validators=[validate_password])
    confirm_new_password = serializers.CharField(required=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_new_password']:
            raise serializers.ValidationError({"new_password": "Passwords don't match"})
        return attrs


class SubjectSerializer(serializers.ModelSerializer):
    notes_count = serializers.SerializerMethodField()

    class Meta:
        model = Subject
        fields = ['id', 'name', 'description', 'icon', 'color', 'notes_count', 'created_at']

    def get_notes_count(self, obj):
        return obj.notes.count()


class NoteListSerializer(serializers.ModelSerializer):
    uploaded_by = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    is_bookmarked = serializers.SerializerMethodField()
    comments_count = serializers.SerializerMethodField()

    class Meta:
        model = Note
        fields = ['id', 'title', 'description', 'thumbnail', 'subject', 'uploaded_by',
                  'downloads_count', 'views_count', 'tags', 'is_bookmarked', 
                  'comments_count', 'created_at']

    def get_is_bookmarked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Bookmark.objects.filter(note=obj, user=request.user).exists()
        return False

    def get_comments_count(self, obj):
        return obj.comments.count()


class NoteDetailSerializer(serializers.ModelSerializer):
    uploaded_by = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    is_bookmarked = serializers.SerializerMethodField()
    comments_count = serializers.SerializerMethodField()
    is_downloaded = serializers.SerializerMethodField()

    class Meta:
        model = Note
        fields = ['id', 'title', 'description', 'file', 'thumbnail', 'subject', 
                  'uploaded_by', 'downloads_count', 'views_count', 'tags', 
                  'is_bookmarked', 'is_downloaded', 'comments_count', 'created_at', 'updated_at']

    def get_is_bookmarked(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Bookmark.objects.filter(note=obj, user=request.user).exists()
        return False

    def get_is_downloaded(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Download.objects.filter(note=obj, user=request.user).exists()
        return False

    def get_comments_count(self, obj):
        return obj.comments.count()


class NoteCreateSerializer(serializers.ModelSerializer):
    subject_id = serializers.IntegerField(write_only=True, required=False)
    subject_name = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = Note
        fields = ['id', 'title', 'description', 'file', 'thumbnail', 'subject_id', 'subject_name', 'tags']

    def validate(self, attrs):
        if not attrs.get('subject_id') and not attrs.get('subject_name'):
            raise serializers.ValidationError("Either subject_id or subject_name is required")
        return attrs

    def create(self, validated_data):
        subject_id = validated_data.pop('subject_id', None)
        subject_name = validated_data.pop('subject_name', None)
        
        if subject_id:
            subject = Subject.objects.get(id=subject_id)
        elif subject_name:
            subject, _ = Subject.objects.get_or_create(
                name=subject_name,
                defaults={'description': f'Notes for {subject_name}'}
            )
        
        validated_data['subject'] = subject
        validated_data['uploaded_by'] = self.context['request'].user
        return super().create(validated_data)


class NoteRequestListSerializer(serializers.ModelSerializer):
    requested_by = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)
    comments_count = serializers.SerializerMethodField()

    class Meta:
        model = NoteRequest
        fields = ['id', 'title', 'description', 'subject', 'requested_by', 
                  'status', 'comments_count', 'created_at']

    def get_comments_count(self, obj):
        return obj.comments.count()


class NoteRequestCreateSerializer(serializers.ModelSerializer):
    subject_id = serializers.IntegerField(write_only=True, required=False)
    subject_name = serializers.CharField(write_only=True, required=False)
    requested_by = UserSerializer(read_only=True)
    subject = SubjectSerializer(read_only=True)

    class Meta:
        model = NoteRequest
        fields = ['id', 'title', 'description', 'subject_id', 'subject_name', 'subject', 'requested_by', 
                  'status', 'created_at']
        read_only_fields = ['id', 'status', 'created_at']

    def create(self, validated_data):
        subject_id = validated_data.pop('subject_id', None)
        subject_name = validated_data.pop('subject_name', None)
        
        subject = None
        if subject_id:
            try:
                subject = Subject.objects.get(id=subject_id)
            except Subject.DoesNotExist:
                pass
        elif subject_name:
            subject, _ = Subject.objects.get_or_create(
                name=subject_name,
                defaults={'description': f'Requests for {subject_name}', 'icon': 'help_outline', 'color': '#FF4081'}
            )

        if subject:
            validated_data['subject'] = subject
            
        validated_data['requested_by'] = self.context['request'].user
        return super().create(validated_data)


class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    replies = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = ['id', 'content_type', 'text', 'attachment', 'user', 
                  'parent', 'replies', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']

    def get_replies(self, obj):
        if obj.replies.exists():
            return CommentSerializer(obj.replies.all(), many=True).data
        return []


class CommentCreateSerializer(serializers.ModelSerializer):
    note_id = serializers.IntegerField(required=False)
    request_id = serializers.IntegerField(required=False)

    class Meta:
        model = Comment
        fields = ['id', 'content_type', 'note_id', 'request_id', 'text', 
                  'attachment', 'parent']

    def validate(self, attrs):
        content_type = attrs.get('content_type')
        if content_type == 'note' and not attrs.get('note_id'):
            raise serializers.ValidationError({"note_id": "Required for note comments"})
        if content_type == 'request' and not attrs.get('request_id'):
            raise serializers.ValidationError({"request_id": "Required for request comments"})
        return attrs

    def create(self, validated_data):
        note_id = validated_data.pop('note_id', None)
        request_id = validated_data.pop('request_id', None)
        
        if note_id:
            validated_data['note'] = Note.objects.get(id=note_id)
        if request_id:
            validated_data['request'] = NoteRequest.objects.get(id=request_id)
        
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)


class BookmarkSerializer(serializers.ModelSerializer):
    note = NoteListSerializer(read_only=True)

    class Meta:
        model = Bookmark
        fields = ['id', 'note', 'created_at']


class DownloadSerializer(serializers.ModelSerializer):
    note = NoteListSerializer(read_only=True)

    class Meta:
        model = Download
        fields = ['id', 'note', 'downloaded_at']


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'message', 'is_read', 'created_at']
        read_only_fields = ['id', 'created_at']
