/// Remote public images used across the prototype (Unsplash).
/// Local [portfolioP1]–[portfolioP4] are design-work samples for portfolios only.
abstract final class AppAssets {
  static const logo = 'assets/branding/smooth_logo.png';

  /// Design portfolio samples (previous work) — not for avatars or hub banners.
  static const portfolioP1 = 'assets/branding/portfolio/P1.jpeg';
  static const portfolioP2 = 'assets/branding/portfolio/P2.jpeg';
  static const portfolioP3 = 'assets/branding/portfolio/P3.jpeg';
  static const portfolioP4 = 'assets/branding/portfolio/P4.jpeg';

  static const List<String> portfolioDesigns = [portfolioP1, portfolioP2, portfolioP3, portfolioP4];

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

  /// Hub section hero backgrounds (office / facilities photos).
  static const hubFacilitiesCover = heroOffice;
  static const hubRoomsCover =
      'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=1200&q=80';
  static const hubPrintCover =
      'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=1200&q=80';
  static const hubContactCover = heroWorkspace;

  static const avatar1 =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80';
  static const avatar2 =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80';
  static const avatar3 =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80';
  static const avatar4 =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80';

  static const List<String> profileAvatars = [avatar1, avatar2, avatar3, avatar4];

  static const profileCoverLearner =
      'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200&q=80';
  static const profileCoverCreator =
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=1200&q=80';
  static const profileCoverClient =
      'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=1200&q=80';

  static const portfolioBrand = portfolioP1;
  static const portfolioMobile = portfolioP2;
  static const portfolioWeb = portfolioP3;
  static const portfolioDashboard = portfolioP4;

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
