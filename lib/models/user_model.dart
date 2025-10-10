class UserModel {
  final int id;
  final String username;
  final String email;
  final String? name;
  final String role;
  final bool isOrganizer;
  final bool isApproved;
  final int rating;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    required this.role,
    required this.isOrganizer,
    required this.isApproved,
    required this.rating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      role: json['role'] ?? 'volunteer',
      isOrganizer: json['is_organizer'] ?? false,
      isApproved: json['is_approved'] ?? (json['role'] == 'volunteer' ? true : false),
      rating: json['rating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'role': role,
      'is_organizer': isOrganizer,
      'is_approved': isApproved,
      'rating': rating,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? name,
    String? role,
    bool? isOrganizer,
    bool? isApproved,
    int? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isOrganizer: isOrganizer ?? this.isOrganizer,
      isApproved: isApproved ?? this.isApproved,
      rating: rating ?? this.rating,
    );
  }
}
