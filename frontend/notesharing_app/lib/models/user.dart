class User {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String? profilePicture;
  final String? bio;
  final String? college;
  final String? course;
  final String? year;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.profilePicture,
    this.bio,
    this.college,
    this.course,
    this.year,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'] ?? '',
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      college: json['college'],
      course: json['course'],
      year: json['year'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'bio': bio,
      'college': college,
      'course': course,
      'year': year,
    };
  }
}
