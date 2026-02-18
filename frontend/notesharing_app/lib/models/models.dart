import 'user.dart';

class Subject {
  final int id;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final int notesCount;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.notesCount,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'] ?? 'book',
      color: json['color'] ?? '#6366F1',
      notesCount: json['notes_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Note {
  final int id;
  final String title;
  final String description;
  final String? file;
  final String? thumbnail;
  final Subject? subject;
  final User? uploadedBy;
  final int downloadsCount;
  final int viewsCount;
  final String? tags;
  final bool isBookmarked;
  final bool isDownloaded;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.description,
    this.file,
    this.thumbnail,
    this.subject,
    this.uploadedBy,
    required this.downloadsCount,
    required this.viewsCount,
    this.tags,
    this.isBookmarked = false,
    this.isDownloaded = false,
    required this.commentsCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      file: json['file'],
      thumbnail: json['thumbnail'],
      subject: json['subject'] != null ? Subject.fromJson(json['subject']) : null,
      uploadedBy: json['uploaded_by'] != null ? User.fromJson(json['uploaded_by']) : null,
      downloadsCount: json['downloads_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      tags: json['tags'],
      isBookmarked: json['is_bookmarked'] ?? false,
      isDownloaded: json['is_downloaded'] ?? false,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Note copyWith({bool? isBookmarked, int? downloadsCount}) {
    return Note(
      id: id,
      title: title,
      description: description,
      file: file,
      thumbnail: thumbnail,
      subject: subject,
      uploadedBy: uploadedBy,
      downloadsCount: downloadsCount ?? this.downloadsCount,
      viewsCount: viewsCount,
      tags: tags,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isDownloaded: isDownloaded,
      commentsCount: commentsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class NoteRequest {
  final int id;
  final String title;
  final String description;
  final Subject? subject;
  final User? requestedBy;
  final String status;
  final int commentsCount;
  final DateTime createdAt;

  NoteRequest({
    required this.id,
    required this.title,
    required this.description,
    this.subject,
    this.requestedBy,
    required this.status,
    required this.commentsCount,
    required this.createdAt,
  });

  factory NoteRequest.fromJson(Map<String, dynamic> json) {
    return NoteRequest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'] != null ? Subject.fromJson(json['subject']) : null,
      requestedBy: json['requested_by'] != null ? User.fromJson(json['requested_by']) : null,
      status: json['status'] ?? 'open',
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Comment {
  final int id;
  final String contentType;
  final String text;
  final String? attachment;
  final User? user;
  final int? parent;
  final List<Comment> replies;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.contentType,
    required this.text,
    this.attachment,
    this.user,
    this.parent,
    this.replies = const [],
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      contentType: json['content_type'] ?? 'note',
      text: json['text'],
      attachment: json['attachment'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      parent: json['parent'],
      replies: json['replies'] != null
          ? (json['replies'] as List).map((e) => Comment.fromJson(e)).toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class DashboardStats {
  final int totalUploads;
  final int totalDownloads;
  final int totalBookmarks;
  final int totalRequests;
  final int openRequests;
  final int totalNotes;

  DashboardStats({
    required this.totalUploads,
    required this.totalDownloads,
    required this.totalBookmarks,
    required this.totalRequests,
    required this.openRequests,
    required this.totalNotes,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUploads: json['total_uploads'] ?? 0,
      totalDownloads: json['total_downloads'] ?? 0,
      totalBookmarks: json['total_bookmarks'] ?? 0,
      totalRequests: json['total_requests'] ?? 0,
      openRequests: json['open_requests'] ?? 0,
      totalNotes: json['total_notes'] ?? 0,
    );
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
