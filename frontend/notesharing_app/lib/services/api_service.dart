import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/models.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // For iOS Simulator
  // static const String baseUrl = 'http://YOUR_IP:8000/api'; // For physical device

  String? _token;

  Future<String?> get token async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Map<String, String>> get headers async {
    final authToken = await token;
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Token $authToken',
    };
  }

  // ==================== AUTH ====================

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
    String? college,
    String? course,
    String? year,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'full_name': fullName,
        'password': password,
        'password_confirm': password,
        'college': college,
        'course': course,
        'year': year,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await setToken(data['token']);
      return {'success': true, 'user': User.fromJson(data['user'])};
    }
    return {'success': false, 'error': data};
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await setToken(data['token']);
      return {'success': true, 'user': User.fromJson(data['user'])};
    }
    return {'success': false, 'error': data['error'] ?? 'Login failed'};
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
        headers: await headers,
      );
    } catch (e) {
      // Ignore errors
    }
    await clearToken();
  }

  Future<User?> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // ==================== SUBJECTS ====================

  Future<List<Subject>> getSubjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data is List ? data : data['results'] ?? [];
      return results.map<Subject>((json) => Subject.fromJson(json)).toList();
    }
    return [];
  }

  // ==================== NOTES ====================

  Future<List<Note>> getNotes({int? subjectId, String? search, bool myNotes = false}) async {
    String url = '$baseUrl/notes/?';
    if (subjectId != null) url += 'subject=$subjectId&';
    if (search != null && search.isNotEmpty) url += 'search=$search&';
    if (myNotes) url += 'my_notes=true&';

    final response = await http.get(
      Uri.parse(url),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data is List ? data : data['results'] ?? [];
      return results.map<Note>((json) => Note.fromJson(json)).toList();
    }
    return [];
  }

  Future<Note?> getNoteDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notes/$id/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      return Note.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Map<String, dynamic>> uploadNote({
    required String title,
    required String description,
    int? subjectId,
    String? subjectName,
    required File file,
    String? tags,
  }) async {
    final authToken = await token;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/notes/'),
    );

    request.headers['Authorization'] = 'Token $authToken';
    request.fields['title'] = title;
    request.fields['description'] = description;
    
    if (subjectId != null) {
      request.fields['subject_id'] = subjectId.toString();
    } else if (subjectName != null) {
      request.fields['subject_name'] = subjectName;
    }
    
    if (tags != null) request.fields['tags'] = tags;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return {'success': true, 'note': Note.fromJson(jsonDecode(response.body))};
    }
    return {'success': false, 'error': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> downloadNote(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes/$id/download/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'error': 'Download failed'};
  }

  Future<bool> toggleBookmark(int noteId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes/$noteId/bookmark/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['bookmarked'] ?? false;
    }
    return false;
  }

  // ==================== NOTE REQUESTS ====================

  Future<List<NoteRequest>> getNoteRequests({int? subjectId, String? status, String? search, bool myRequests = false}) async {
    String url = '$baseUrl/requests/?';
    if (subjectId != null) url += 'subject=$subjectId&';
    if (status != null) url += 'status=$status&';
    if (search != null && search.isNotEmpty) url += 'search=$search&';
    if (myRequests) url += 'my_requests=true&';

    final response = await http.get(
      Uri.parse(url),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data is List ? data : data['results'] ?? [];
      return results.map<NoteRequest>((json) => NoteRequest.fromJson(json)).toList();
    }
    return [];
  }

  Future<NoteRequest?> getRequestDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/requests/$id/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      return NoteRequest.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Map<String, dynamic>> createNoteRequest({
    required String title,
    required String description,
    int? subjectId,
    String? subjectName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requests/'),
      headers: await headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        if (subjectId != null) 'subject_id': subjectId,
        if (subjectName != null && subjectName.isNotEmpty) 'subject_name': subjectName,
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'request': NoteRequest.fromJson(jsonDecode(response.body))};
    }
    return {'success': false, 'error': jsonDecode(response.body)};
  }

  // ==================== COMMENTS ====================

  Future<List<Comment>> getComments({int? noteId, int? requestId}) async {
    String url = '$baseUrl/comments/?';
    if (noteId != null) url += 'note=$noteId&';
    if (requestId != null) url += 'request=$requestId&';

    final response = await http.get(
      Uri.parse(url),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data is List ? data : data['results'] ?? [];
      return results.map<Comment>((json) => Comment.fromJson(json)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createComment({
    required String contentType,
    int? noteId,
    int? requestId,
    required String text,
    File? attachment,
  }) async {
    if (attachment != null) {
      final authToken = await token;
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/comments/'),
      );
      request.headers['Authorization'] = 'Token $authToken';
      request.fields['content_type'] = contentType;
      if (noteId != null) request.fields['note_id'] = noteId.toString();
      if (requestId != null) request.fields['request_id'] = requestId.toString();
      request.fields['text'] = text;
      request.files.add(await http.MultipartFile.fromPath('attachment', attachment.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'comment': Comment.fromJson(jsonDecode(response.body))};
      }
      return {'success': false, 'error': jsonDecode(response.body)};
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl/comments/'),
        headers: await headers,
        body: jsonEncode({
          'content_type': contentType,
          if (noteId != null) 'note_id': noteId,
          if (requestId != null) 'request_id': requestId,
          'text': text,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'comment': Comment.fromJson(jsonDecode(response.body))};
      }
      return {'success': false, 'error': jsonDecode(response.body)};
    }
  }

  // ==================== BOOKMARKS & DOWNLOADS ====================

  Future<List<Note>> getMyBookmarks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my/bookmarks/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Note>((json) => Note.fromJson(json['note'])).toList();
    }
    return [];
  }

  Future<List<Note>> getMyDownloads() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my/downloads/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Note>((json) => Note.fromJson(json['note'])).toList();
    }
    return [];
  }

  // ==================== DASHBOARD ====================

  Future<DashboardStats?> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/'),
      headers: await headers,
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // ==================== NOTIFICATIONS ====================

  Future<List<NotificationModel>> getNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/'), headers: await headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : data['results'] ?? [];
      return list.map<NotificationModel>((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> markNotificationsRead() async {
    await http.post(
      Uri.parse('$baseUrl/notifications/mark_all_read/'),
      headers: await headers,
    );
  }

  Future<User?> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: await headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password/'),
      headers: await headers,
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_new_password': confirmPassword,
      }),
    );
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Password updated successfully'};
    }
    return {'success': false, 'error': jsonDecode(response.body)};
  }
}
