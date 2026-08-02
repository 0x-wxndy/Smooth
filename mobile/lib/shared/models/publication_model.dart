class Publication {
  const Publication({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.hashtags,
    required this.imagePaths,
    required this.kind,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String body;
  final List<String> hashtags;
  final List<String> imagePaths;
  final String kind;
  final String createdAt;

  bool get isAnnouncement => kind == 'announcement';
  bool get isOffer => kind == 'offer';
}

class EnrolledStudent {
  const EnrolledStudent({
    required this.userId,
    required this.displayName,
    required this.courseId,
    required this.courseTitle,
    required this.progressPercent,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final String courseId;
  final String courseTitle;
  final double progressPercent;
  final String? avatarUrl;
}

class TeacherEnrollmentStats {
  const TeacherEnrollmentStats({
    required this.totalStudents,
    required this.students,
  });

  final int totalStudents;
  final List<EnrolledStudent> students;
}
