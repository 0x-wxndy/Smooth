import '../../shared/models/course_model.dart';

abstract final class AppConstants {
  static const categories = [
    ('Dev', CourseCategory.softwareDev),
    ('Design', CourseCategory.uiUx),
    ('Marketing', CourseCategory.digitalMarketing),
    ('Security', CourseCategory.cybersecurity),
    ('AI', CourseCategory.ai),
    ('Business', CourseCategory.business),
  ];
}
