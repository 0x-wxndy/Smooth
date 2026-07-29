/// Bundled offline lesson videos (Programming Essentials / Flutter course).
abstract final class LessonVideos {
  static const folder = 'videos';

  static const lesson1 = '$folder/programming_essencials_1.mp4';
  static const lesson2 = '$folder/programming_essencials_2.mp4';
  static const lesson3 = '$folder/prog_ess3.mp4';
  static const lesson4 = '$folder/prog_essencials_4.mp4';
  static const lesson5 = '$folder/prog_essencials_5.mp4';

  static const Map<String, String> byLessonId = {
    'lesson_1': lesson1,
    'lesson_2': lesson2,
    'lesson_3': lesson3,
    'lesson_4': lesson4,
    'lesson_5': lesson5,
  };

  static String? assetFor(String lessonId) => byLessonId[lessonId];
}
