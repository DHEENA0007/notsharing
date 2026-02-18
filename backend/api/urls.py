from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'subjects', views.SubjectViewSet)
router.register(r'notes', views.NoteViewSet)
router.register(r'requests', views.NoteRequestViewSet)
router.register(r'comments', views.CommentViewSet)
router.register(r'notifications', views.NotificationViewSet, basename='notification')

urlpatterns = [
    # Auth routes
    path('auth/register/', views.register, name='register'),
    path('auth/login/', views.login, name='login'),
    path('auth/logout/', views.logout, name='logout'),
    path('auth/profile/', views.profile, name='profile'),
    path('auth/change-password/', views.change_password, name='change-password'),
    
    # User specific routes
    path('my/bookmarks/', views.my_bookmarks, name='my-bookmarks'),
    path('my/downloads/', views.my_downloads, name='my-downloads'),
    path('dashboard/', views.dashboard_stats, name='dashboard'),
    
    # Router URLs
    path('', include(router.urls)),
]
