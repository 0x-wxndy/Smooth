enum CourseCategory {
  softwareDev,
  uiUx,
  graphicDesign,
  digitalMarketing,
  cybersecurity,
  ai,
  languages,
  business,
  other,
}

enum Difficulty { beginner, intermediate, advanced }

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationMinutes,
    required this.skills,
    required this.isFree,
    this.priceCents,
    this.thumbnailUrl,
    this.ratingAvg = 0,
    this.enrollmentCount = 0,
    this.progressPercent,
    this.teacherName,
    this.teacherAvatar,
  });

  final String id;
  final String title;
  final String description;
  final CourseCategory category;
  final Difficulty difficulty;
  final int durationMinutes;
  final List<String> skills;
  final bool isFree;
  final int? priceCents;
  final String? thumbnailUrl;
  final double ratingAvg;
  final int enrollmentCount;
  final double? progressPercent;
  final String? teacherName;
  final String? teacherAvatar;

  String get durationLabel {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  String get priceLabel {
    if (isFree) return 'Free';
    return '\$${((priceCents ?? 0) / 100).toStringAsFixed(0)}';
  }

  String get difficultyLabel {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }
}

class CourseModule {
  const CourseModule({
    required this.id,
    required this.title,
    required this.lessons,
  });

  final String id;
  final String title;
  final List<Lesson> lessons;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.completed = false,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final bool completed;
}
