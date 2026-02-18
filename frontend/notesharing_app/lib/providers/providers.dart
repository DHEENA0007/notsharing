import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<bool> checkAuth() async {
    final token = await _api.token;
    if (token != null) {
      _user = await _api.getProfile();
      notifyListeners();
      return _user != null;
    }
    return false;
  }

  Future<bool> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
    String? college,
    String? course,
    String? year,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.register(
      email: email,
      username: username,
      fullName: fullName,
      password: password,
      college: college,
      course: course,
      year: year,
    );

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    }
    _error = result['error'].toString();
    notifyListeners();
    return false;
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.login(email: email, password: password);

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    }
    _error = result['error'].toString();
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final updatedUser = await _api.updateProfile(data);
    _isLoading = false;
    if (updatedUser != null) {
      _user = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.changePassword(
        oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword);
    _isLoading = false;
    notifyListeners();
    return result;
  }
}

class NotesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Note> _notes = [];
  List<Subject> _subjects = [];
  List<Note> _myNotes = [];
  List<Note> _bookmarks = [];
  List<Note> _downloads = [];
  DashboardStats? _stats;
  bool _isLoading = false;

  List<Note> get notes => _notes;
  List<Subject> get subjects => _subjects;
  List<Note> get myNotes => _myNotes;
  List<Note> get bookmarks => _bookmarks;
  List<Note> get downloads => _downloads;
  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> loadSubjects() async {
    _subjects = await _api.getSubjects();
    notifyListeners();
  }

  Future<void> loadNotes({int? subjectId, String? search}) async {
    _isLoading = true;
    notifyListeners();

    _notes = await _api.getNotes(subjectId: subjectId, search: search);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyNotes() async {
    _myNotes = await _api.getNotes(myNotes: true);
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    _bookmarks = await _api.getMyBookmarks();
    notifyListeners();
  }

  Future<void> loadDownloads() async {
    _downloads = await _api.getMyDownloads();
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _stats = await _api.getDashboardStats();
    notifyListeners();
  }

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  Future<void> loadNotifications() async {
    _notifications = await _api.getNotifications();
    notifyListeners();
  }

  Future<void> markNotificationsRead() async {
    await _api.markNotificationsRead();
    await loadNotifications();
  }

  Future<bool> toggleBookmark(int noteId) async {
    final result = await _api.toggleBookmark(noteId);
    
    // Update local state
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isBookmarked: result);
    }
    
    await loadBookmarks();
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> downloadNote(int noteId) async {
    final result = await _api.downloadNote(noteId);
    await loadDownloads();
    return result;
  }

  Future<bool> uploadNote({
    required String title,
    required String description,
    required File file,
    int? subjectId,
    String? subjectName,
    String? tags,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.uploadNote(
      title: title,
      description: description,
      file: file,
      subjectId: subjectId,
      subjectName: subjectName,
      tags: tags,
    );

    _isLoading = false;
    if (result['success']) {
      await loadNotes();
      await loadSubjects(); // Refresh subjects list for new additions
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }
}

class RequestsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<NoteRequest> _requests = [];
  List<NoteRequest> _myRequests = [];
  bool _isLoading = false;

  List<NoteRequest> get requests => _requests;
  List<NoteRequest> get myRequests => _myRequests;
  bool get isLoading => _isLoading;

  Future<void> loadRequests({int? subjectId, String? status, String? search}) async {
    _isLoading = true;
    notifyListeners();

    _requests = await _api.getNoteRequests(
      subjectId: subjectId,
      status: status,
      search: search,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyRequests() async {
    _myRequests = await _api.getNoteRequests(myRequests: true);
    notifyListeners();
  }

  Future<bool> createRequest({
    required String title,
    required String description,
    int? subjectId,
    String? subjectName,
  }) async {
    final result = await _api.createNoteRequest(
      title: title,
      description: description,
      subjectId: subjectId,
      subjectName: subjectName,
    );

    if (result['success']) {
      await loadRequests();
      await loadMyRequests();
      return true;
    }
    return false;
  }
}
