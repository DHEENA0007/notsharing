from rest_framework import viewsets, status, generics
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from django.contrib.auth import get_user_model
from django.db.models import Q
from .models import Subject, Note, NoteRequest, Comment, Download, Bookmark, Notification
from .serializers import (
    UserSerializer, UserRegisterSerializer, UserLoginSerializer, ChangePasswordSerializer,
    SubjectSerializer, NoteListSerializer, NoteDetailSerializer, NoteCreateSerializer,
    NoteRequestListSerializer, NoteRequestCreateSerializer,
    CommentSerializer, CommentCreateSerializer,
    BookmarkSerializer, DownloadSerializer, NotificationSerializer
)

User = get_user_model()


# ==================== AUTH VIEWS ====================

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """Register a new user"""
    serializer = UserRegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'message': 'Registration successful',
            'user': UserSerializer(user).data,
            'token': token.key
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """Login user"""
    serializer = UserLoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email'].strip()
        password = serializer.validated_data['password']

        user = User.objects.filter(email__iexact=email).first()
        if not user or not user.check_password(password):
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

        if not user.is_active:
            return Response({'error': 'Account is disabled'}, status=status.HTTP_403_FORBIDDEN)

        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'message': 'Login successful',
            'user': UserSerializer(user).data,
            'token': token.key
        })
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    """Logout user"""
    try:
        request.user.auth_token.delete()
        return Response({'message': 'Logout successful'})
    except:
        return Response({'message': 'Logout successful'})


@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def profile(request):
    """Get or update user profile"""
    if request.method == 'GET':
        return Response(UserSerializer(request.user).data)
    
    serializer = UserSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """Change user password"""
    serializer = ChangePasswordSerializer(data=request.data)
    if serializer.is_valid():
        user = request.user
        if not user.check_password(serializer.validated_data['old_password']):
            return Response({'old_password': ['Wrong password.']}, status=status.HTTP_400_BAD_REQUEST)
        
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        return Response({'message': 'Password updated successfully'})
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ==================== SUBJECT VIEWS ====================

class SubjectViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for subjects/categories"""
    queryset = Subject.objects.all()
    serializer_class = SubjectSerializer
    permission_classes = [AllowAny]


# ==================== NOTE VIEWS ====================

class NoteViewSet(viewsets.ModelViewSet):
    """ViewSet for notes"""
    queryset = Note.objects.filter(is_approved=True)
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return NoteCreateSerializer
        if self.action == 'retrieve':
            return NoteDetailSerializer
        return NoteListSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        
        # Filter by subject
        subject_id = self.request.query_params.get('subject')
        if subject_id:
            queryset = queryset.filter(subject_id=subject_id)
        
        # Search
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) | 
                Q(description__icontains=search) |
                Q(tags__icontains=search)
            )
        
        # Filter by user's uploads
        my_notes = self.request.query_params.get('my_notes')
        if my_notes:
            queryset = queryset.filter(uploaded_by=self.request.user)
        
        return queryset

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        # Increment view count
        instance.views_count += 1
        instance.save(update_fields=['views_count'])
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def download(self, request, pk=None):
        """Record download and return file URL"""
        note = self.get_object()
        Download.objects.get_or_create(note=note, user=request.user)
        note.downloads_count += 1
        note.save(update_fields=['downloads_count'])
        return Response({
            'file_url': request.build_absolute_uri(note.file.url),
            'downloads_count': note.downloads_count
        })

    @action(detail=True, methods=['post'])
    def bookmark(self, request, pk=None):
        """Toggle bookmark on a note"""
        note = self.get_object()
        bookmark, created = Bookmark.objects.get_or_create(note=note, user=request.user)
        if not created:
            bookmark.delete()
            return Response({'bookmarked': False, 'message': 'Bookmark removed'})
        return Response({'bookmarked': True, 'message': 'Note bookmarked'})

    @action(detail=True, methods=['get'])
    def comments(self, request, pk=None):
        """Get comments for a note"""
        note = self.get_object()
        comments = note.comments.filter(parent=None)
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data)


# ==================== NOTE REQUEST VIEWS ====================

class NoteRequestViewSet(viewsets.ModelViewSet):
    """ViewSet for note requests"""
    queryset = NoteRequest.objects.all()
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return NoteRequestCreateSerializer
        return NoteRequestListSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        
        # Filter by status
        req_status = self.request.query_params.get('status')
        if req_status:
            queryset = queryset.filter(status=req_status)
        
        # Filter by subject
        subject_id = self.request.query_params.get('subject')
        if subject_id:
            queryset = queryset.filter(subject_id=subject_id)
        
        # Search
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) | Q(description__icontains=search)
            )
        
        # My requests
        my_requests = self.request.query_params.get('my_requests')
        if my_requests:
            queryset = queryset.filter(requested_by=self.request.user)
        
        return queryset

    @action(detail=True, methods=['post'])
    def fulfill(self, request, pk=None):
        """Mark request as fulfilled with a note"""
        note_request = self.get_object()
        note_id = request.data.get('note_id')
        
        if not note_id:
            return Response({'error': 'note_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            note = Note.objects.get(id=note_id)
            note_request.status = 'fulfilled'
            note_request.fulfilled_by = note
            note_request.save()
            
            # Notify the user who requested the note
            if note_request.requested_by != request.user:
                Notification.objects.create(
                    user=note_request.requested_by,
                    title='Request Fulfilled',
                    message=f'Your request "{note_request.title}" was fulfilled by {request.user.full_name}.'
                )
            
            return Response({'message': 'Request marked as fulfilled'})
        except Note.DoesNotExist:
            return Response({'error': 'Note not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['get'])
    def comments(self, request, pk=None):
        """Get comments for a request"""
        note_request = self.get_object()
        comments = note_request.comments.filter(parent=None)
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data)


# ==================== COMMENT VIEWS ====================

class CommentViewSet(viewsets.ModelViewSet):
    """ViewSet for comments"""
    queryset = Comment.objects.all()
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return CommentCreateSerializer
        return CommentSerializer

    def perform_create(self, serializer):
        comment = serializer.save(user=self.request.user)
        
        # Notify note owner
        if comment.note and comment.note.uploaded_by != self.request.user:
            Notification.objects.create(
                user=comment.note.uploaded_by,
                title='New Comment on Note',
                message=f'{self.request.user.full_name} commented on your note "{comment.note.title}".'
            )
        # Notify request owner
        elif comment.request and comment.request.requested_by != self.request.user:
             Notification.objects.create(
                user=comment.request.requested_by,
                title='New Comment on Request',
                message=f'{self.request.user.full_name} commented on your request "{comment.request.title}".'
            )

    def get_queryset(self):
        queryset = super().get_queryset()
        
        # Filter by note
        note_id = self.request.query_params.get('note')
        if note_id:
            queryset = queryset.filter(note_id=note_id, parent=None)
        
        # Filter by request
        request_id = self.request.query_params.get('request')
        if request_id:
            queryset = queryset.filter(request_id=request_id, parent=None)
        
        return queryset


# ==================== BOOKMARK & DOWNLOAD VIEWS ====================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_bookmarks(request):
    """Get user's bookmarked notes"""
    bookmarks = Bookmark.objects.filter(user=request.user)
    serializer = BookmarkSerializer(bookmarks, many=True, context={'request': request})
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_downloads(request):
    """Get user's downloaded notes"""
    downloads = Download.objects.filter(user=request.user)
    serializer = DownloadSerializer(downloads, many=True, context={'request': request})
    return Response(serializer.data)


# ==================== DASHBOARD/STATS ====================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_stats(request):
    """Get dashboard statistics for the user"""
    user = request.user
    return Response({
        'total_uploads': Note.objects.filter(uploaded_by=user).count(),
        'total_downloads': Download.objects.filter(user=user).count(),
        'total_bookmarks': Bookmark.objects.filter(user=user).count(),
        'total_requests': NoteRequest.objects.filter(requested_by=user).count(),
        'open_requests': NoteRequest.objects.filter(status='open').count(),
        'total_notes': Note.objects.filter(is_approved=True).count(),
    })

# ==================== NOTIFICATION VIEWS ====================

class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)

    @action(detail=False, methods=['POST'])
    def mark_all_read(self, request):
        self.get_queryset().update(is_read=True)
        return Response({'status': 'success'})
