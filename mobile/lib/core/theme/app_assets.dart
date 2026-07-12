/// Remote public images used across the prototype (Unsplash).
abstract final class AppAssets {
  static const heroOffice =
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&q=80';
  static const heroWorkspace =
      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1200&q=80';
  static const coverGeometric =
      'https://images.unsplash.com/photo-1557683316-973673baf926?w=1200&q=80';
  static const learningDesk =
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80';
  static const coding =
      'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&q=80';
  static const design =
      'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80';
  static const security =
      'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&q=80';
  static const marketing =
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80';
  static const avatar1 =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80';
  static const avatar2 =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80';
  static const avatar3 =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80';
  static const avatar4 =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80';

  static String courseThumb(String category) {
    switch (category) {
      case 'uiUx':
      case 'graphicDesign':
        return design;
      case 'cybersecurity':
        return security;
      case 'digitalMarketing':
        return marketing;
      default:
        return coding;
    }
  }
}
