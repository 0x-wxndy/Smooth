import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'smooth_locale';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'fr';
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  bool get isRtl => state.languageCode == 'ar';
}

/// Lightweight translations for Smooth (FR / AR / EN).
class S {
  S(this.locale);

  final Locale locale;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S) ?? S(const Locale('fr'));
  }

  String get _code => locale.languageCode;

  String t(String key) {
    final map = _strings[key];
    if (map == null) return key;
    return map[_code] ?? map['fr'] ?? map['en'] ?? key;
  }

  // Convenience getters
  String get appName => t('appName');
  String get marketplaceTitle => t('marketplaceTitle');
  String get searchHint => t('searchHint');
  String get studentView => t('studentView');
  String get proView => t('proView');
  String get freeLibrary => t('freeLibrary');
  String get freeLibrarySub => t('freeLibrarySub');
  String get featuredFreelancers => t('featuredFreelancers');
  String get pendingProjects => t('pendingProjects');
  String get premiumCourses => t('premiumCourses');
  String get offerService => t('offerService');
  String get allServices => t('allServices');
  String get free => t('free');
  String get from => t('from');
  String get perHour => t('perHour');
  String get home => t('home');
  String get learn => t('learn');
  String get market => t('market');
  String get jobs => t('jobs');
  String get profile => t('profile');
  String get dashboard => t('dashboard');
  String get courses => t('courses');
  String get services => t('services');
  String get language => t('language');
  String get welcome => t('welcome');
  String get choosePath => t('choosePath');
  String get startLearning => t('startLearning');
  String get startLearningFree => t('startLearningFree');
  String get bookInHub => t('bookInHub');
  String get homeHeroTitle => t('homeHeroTitle');
  String get homeHeroSubtitle => t('homeHeroSubtitle');
  String get freeLibraryNav => t('freeLibraryNav');
  String get servicesHubNav => t('servicesHubNav');
  String get shopNav => t('shopNav');
  String get aboutNav => t('aboutNav');
  String get signIn => t('signIn');
  String get signOut => t('signOut');
  String get continueLearning => t('continueLearning');
  String get categories => t('categories');
  String get aiAssistant => t('aiAssistant');
  String get games => t('games');
  String get exploreMarket => t('exploreMarket');
  String get streak => t('streak');
  String get coins => t('coins');
  String get xp => t('xp');
  String get rookie => t('rookie');
  String get clientHub => t('clientHub');
  String get clientHeroTitle => t('clientHeroTitle');
  String get clientHeroSubtitle => t('clientHeroSubtitle');
  String get browseFreelancers => t('browseFreelancers');
  String get postAJob => t('postAJob');
  String get topServices => t('topServices');
  String get beginner => t('beginner');
  String get intermediate => t('intermediate');
  String get advanced => t('advanced');
  String get deliveryDays => t('deliveryDays');
  String get price => t('price');
  String get enrollFree => t('enrollFree');
  String get buy => t('buy');
  String get createAccount => t('createAccount');
  String get getStarted => t('getStarted');
  String get alreadyHaveAccount => t('alreadyHaveAccount');
  String get tagline => t('tagline');
  String get heroSubtitle => t('heroSubtitle');
  String get learnerRole => t('learnerRole');
  String get teacherRole => t('teacherRole');
  String get clientRole => t('clientRole');
  String get learnerDesc => t('learnerDesc');
  String get teacherDesc => t('teacherDesc');
  String get clientDesc => t('clientDesc');
  String get startAsCreator => t('startAsCreator');
  String get postProject => t('postProject');
  String get projectVisual => t('projectVisual');
  String get projectAndroid => t('projectAndroid');
  String get graphicDesigner => t('graphicDesigner');
  String get fullstackDev => t('fullstackDev');
  String get uiuxDesigner => t('uiuxDesigner');
  String get editProfile => t('editProfile');
  String get moments => t('moments');
  String get vipBenefits => t('vipBenefits');
  String get viewFeedback => t('viewFeedback');
  String get insightBanner => t('insightBanner');
  String get exploreMasterclasses => t('exploreMasterclasses');
  String get learnHubTitle => t('learnHubTitle');
  String get masterclassAccess => t('masterclassAccess');
  String get sourceFiles => t('sourceFiles');
  String get priorityReview => t('priorityReview');
  String get webinars => t('webinars');
  String get freeCol => t('freeCol');
  String get premiumCol => t('premiumCol');
  String get unlimitedMaster => t('unlimitedMaster');
  String get freePrompts => t('freePrompts');
  String get defaultBio => t('defaultBio');
  String get eduGames => t('eduGames');
  String get eduGamesSub => t('eduGamesSub');
  String get aiTokens => t('aiTokens');
  String get freeToday => t('freeToday');
  String get bonusTokens => t('bonusTokens');
  String get aiUnlockHint => t('aiUnlockHint');
  String get openAi => t('openAi');
  String get unlockTokens => t('unlockTokens');
  String get aiPackSmall => t('aiPackSmall');
  String get aiPackLarge => t('aiPackLarge');
  String get bestValue => t('bestValue');
  String get notEnoughCoins => t('notEnoughCoins');
  String get seeAll => t('seeAll');
  String get filterAll => t('filterAll');
  String get filterPremium => t('filterPremium');
  String get lessonRewardHint => t('lessonRewardHint');
  String get completeLesson => t('completeLesson');
  String get lessonDone => t('lessonDone');
  String get earnRewards => t('earnRewards');

  String tokensUnlocked(int n) => t('tokensUnlocked').replaceAll('{n}', '$n');
  String rewardSnack(int coins, int xp) =>
      t('rewardSnack').replaceAll('{c}', '$coins').replaceAll('{x}', '$xp');

  String get checkout => t('checkout');
  String get orderSummary => t('orderSummary');
  String get total => t('total');
  String get paymentMethod => t('paymentMethod');
  String get mockPaymentNote => t('mockPaymentNote');
  String get selectPaymentMethod => t('selectPaymentMethod');
  String get continueToPay => t('continueToPay');
  String get paymentSuccess => t('paymentSuccess');
  String get paymentFailed => t('paymentFailed');
  String get paymentSuccessCoins => t('paymentSuccessCoins');
  String get mockGateway => t('mockGateway');
  String get edahabiaSecure => t('edahabiaSecure');
  String get merchant => t('merchant');
  String get cardNumber => t('cardNumber');
  String get cardHolder => t('cardHolder');
  String get expiry => t('expiry');
  String get payNow => t('payNow');
  String get confirmPayment => t('confirmPayment');
  String get otpHint => t('otpHint');
  String get otpCode => t('otpCode');
  String get enterOtp => t('enterOtp');
  String get edahabiaDemoTip => t('edahabiaDemoTip');
  String get cibDemoTip => t('cibDemoTip');
  String get amountToPay => t('amountToPay');
  String get cardPayment => t('cardPayment');
  String get order => t('order');
  String get gateway => t('gateway');
  String get amount => t('amount');
  String get reference => t('reference');
  String get paidWithCoins => t('paidWithCoins');
  String get backHome => t('backHome');
  String get openCourse => t('openCourse');
  String get bookNow => t('bookNow');
  String get payWithEdahabia => t('payWithEdahabia');
  String get payDzd => t('payDzd');
  String get postCourse => t('postCourse');
  String get postService => t('postService');
  String get publishCourse => t('publishCourse');
  String get publishService => t('publishService');
  String get courseTitle => t('courseTitle');
  String get serviceTitle => t('serviceTitle');
  String get description => t('description');
  String get difficulty => t('difficulty');
  String get fillRequired => t('fillRequired');
  String get creatorEarnHint => t('creatorEarnHint');
  String get myCourses => t('myCourses');
  String get myServices => t('myServices');
  String get noCoursesYet => t('noCoursesYet');
  String get noServicesYet => t('noServicesYet');
  String get createFirstCourse => t('createFirstCourse');
  String get createFirstService => t('createFirstService');
  String get newCourse => t('newCourse');
  String get newService => t('newService');
  String get claimRatingBonus => t('claimRatingBonus');
  String get bonusAlreadyClaimed => t('bonusAlreadyClaimed');
  String get creatorMarketTitle => t('creatorMarketTitle');
  String get clientMarketTitle => t('clientMarketTitle');
  String get clientMarketSub => t('clientMarketSub');
  String get hireTalent => t('hireTalent');
  String get myListings => t('myListings');
  String get jobOffers => t('jobOffers');
  String get applyJobsHint => t('applyJobsHint');
  String get clientRequests => t('clientRequests');
  String get creatorActions => t('creatorActions');
  String get browseJobs => t('browseJobs');
  String get creatorStudio => t('creatorStudio');
  String get teacherHeroTitle => t('teacherHeroTitle');
  String get teacherHeroSubtitle => t('teacherHeroSubtitle');

  String coursePostedReward(int n) => t('coursePostedReward').replaceAll('{n}', '$n');
  String servicePostedReward(int n) => t('servicePostedReward').replaceAll('{n}', '$n');
  String ratingBonusClaimed(int n) => t('ratingBonusClaimed').replaceAll('{n}', '$n');
  String get tryDemoAccounts => t('tryDemoAccounts');
  String get demoTapLogin => t('demoTapLogin');
  String get demoLearnerLabel => t('demoLearnerLabel');
  String get demoTeacherLabel => t('demoTeacherLabel');
  String get demoClientLabel => t('demoClientLabel');

  static const _strings = <String, Map<String, String>>{
    'appName': {'en': 'Smooth Hub', 'fr': 'Smooth Hub', 'ar': 'سموث هب'},
    'marketplaceTitle': {
      'en': 'Services & lessons market',
      'fr': 'Marché des services et cours',
      'ar': 'سوق الخدمات والدروس',
    },
    'searchHint': {
      'en': 'Search lessons or freelancers…',
      'fr': 'Rechercher des cours ou freelances…',
      'ar': 'ابحث عن دروس أو مستقلين',
    },
    'studentView': {
      'en': 'Student view',
      'fr': 'Vue étudiants',
      'ar': 'عرض الطلاب',
    },
    'proView': {
      'en': 'Pros / teachers / freelancers',
      'fr': 'Pros / enseignants / freelances',
      'ar': 'عرض المحترفين / المعلمين / المستقلين',
    },
    'freeLibrary': {
      'en': 'Free lessons library',
      'fr': 'Bibliothèque de cours gratuits',
      'ar': 'دروس مجانية من YouTube ومنصات أخرى',
    },
    'freeLibrarySub': {
      'en': 'Free lessons from YouTube and other platforms',
      'fr': 'Cours gratuits depuis YouTube et d’autres plateformes',
      'ar': 'دروس مجانية من YouTube ومنصات أخرى',
    },
    'featuredFreelancers': {
      'en': 'Featured freelancer services',
      'fr': 'Services freelances en vedette',
      'ar': 'خدمات المستقلين المميزة',
    },
    'pendingProjects': {
      'en': 'Pending project requests',
      'fr': 'Demandes de projets en attente',
      'ar': 'طلبات مشاريع قيد الانتظار',
    },
    'premiumCourses': {
      'en': 'Advanced paid courses',
      'fr': 'Cours avancés payants',
      'ar': 'دورات متقدمة ومدفوعة',
    },
    'offerService': {
      'en': 'Offer a service / lesson',
      'fr': 'Proposer un service / cours',
      'ar': 'تقديم خدمة / درس',
    },
    'allServices': {'en': 'All services', 'fr': 'Tous les services', 'ar': 'كل الخدمات'},
    'free': {'en': 'Free', 'fr': 'Gratuit', 'ar': 'مجاني'},
    'from': {'en': 'From', 'fr': 'À partir de', 'ar': 'ابتداءً من'},
    'perHour': {'en': '/hr', 'fr': '/h', 'ar': '/ساعة'},
    'home': {'en': 'Home', 'fr': 'Accueil', 'ar': 'الرئيسية'},
    'learn': {'en': 'Learn', 'fr': 'Apprendre', 'ar': 'تعلّم'},
    'market': {'en': 'Market', 'fr': 'Marché', 'ar': 'السوق'},
    'jobs': {'en': 'Jobs', 'fr': 'Emplois', 'ar': 'وظائف'},
    'profile': {'en': 'Profile', 'fr': 'Profil', 'ar': 'حسابي'},
    'dashboard': {'en': 'Dashboard', 'fr': 'Tableau', 'ar': 'لوحة التحكم'},
    'courses': {'en': 'Courses', 'fr': 'Cours', 'ar': 'الدورات'},
    'services': {'en': 'Services', 'fr': 'Services', 'ar': 'الخدمات'},
    'language': {'en': 'Language', 'fr': 'Langue', 'ar': 'اللغة'},
    'welcome': {'en': 'Welcome!', 'fr': 'Bienvenue !', 'ar': 'أهلاً بك!'},
    'choosePath': {'en': 'Choose your path', 'fr': 'Choisissez votre parcours', 'ar': 'اختر مسارك'},
    'startLearning': {'en': 'Start learning', 'fr': 'Commencer à apprendre', 'ar': 'ابدأ التعلم'},
    'startLearningFree': {
      'en': 'Start Learning (Free)',
      'fr': 'Commencer (Gratuit)',
      'ar': 'ابدأ التعلم (مجاناً)',
    },
    'bookInHub': {
      'en': 'Book in the Hub',
      'fr': 'Réserver au Hub',
      'ar': 'احجز في الهب',
    },
    'homeHeroTitle': {
      'en': 'Smooth Hub: Your Integrated Tech Ecosystem',
      'fr': 'Smooth Hub : votre écosystème tech intégré',
      'ar': 'سموث هب: نظامك التقني المتكامل',
    },
    'homeHeroSubtitle': {
      'en': 'Learn, Create, and Connect in a Professional Environment.',
      'fr': 'Apprenez, créez et connectez-vous dans un environnement pro.',
      'ar': 'تعلّم، أنشئ، وتواصل في بيئة مهنية.',
    },
    'freeLibraryNav': {'en': 'Free Library', 'fr': 'Bibliothèque', 'ar': 'المكتبة'},
    'servicesHubNav': {'en': 'Services Hub', 'fr': 'Services', 'ar': 'الخدمات'},
    'shopNav': {'en': 'Shop', 'fr': 'Boutique', 'ar': 'المتجر'},
    'aboutNav': {'en': 'About Us', 'fr': 'À propos', 'ar': 'من نحن'},
    'signIn': {'en': 'Sign in', 'fr': 'Connexion', 'ar': 'تسجيل الدخول'},
    'signOut': {'en': 'Sign out', 'fr': 'Déconnexion', 'ar': 'تسجيل الخروج'},
    'continueLearning': {
      'en': 'Continue learning',
      'fr': 'Continuer l’apprentissage',
      'ar': 'متابعة التعلم',
    },
    'categories': {'en': 'Categories', 'fr': 'Catégories', 'ar': 'الفئات'},
    'aiAssistant': {'en': 'AI Assistant', 'fr': 'Assistant IA', 'ar': 'مساعد الذكاء الاصطناعي'},
    'games': {'en': 'Games', 'fr': 'Jeux', 'ar': 'ألعاب'},
    'exploreMarket': {
      'en': 'Explore marketplace',
      'fr': 'Explorer le marché',
      'ar': 'استكشف السوق',
    },
    'streak': {'en': 'Streak', 'fr': 'Série', 'ar': 'السلسلة'},
    'coins': {'en': 'Coins', 'fr': 'Pièces', 'ar': 'عملات'},
    'xp': {'en': 'XP', 'fr': 'XP', 'ar': 'XP'},
    'rookie': {'en': 'Rookie', 'fr': 'Débutant', 'ar': 'مبتدئ'},
    'clientHub': {'en': 'Client Hub', 'fr': 'Espace client', 'ar': 'مساحة العميل'},
    'clientHeroTitle': {
      'en': 'Smooth Hub: Hire Talent. Ship Faster.',
      'fr': 'Smooth Hub : recrutez. Livrez plus vite.',
      'ar': 'سموث هب: وظّف المواهب وأنجز أسرع',
    },
    'clientHeroSubtitle': {
      'en': 'Find freelancers, book sessions, and post jobs in one professional space.',
      'fr': 'Trouvez des freelances, réservez des sessions et publiez des missions.',
      'ar': 'اعثر على مستقلين، احجز جلسات، وانشر وظائف في مساحة واحدة.',
    },
    'browseFreelancers': {
      'en': 'Browse freelancers',
      'fr': 'Parcourir les freelances',
      'ar': 'تصفح المستقلين',
    },
    'postAJob': {'en': 'Post a job', 'fr': 'Publier une mission', 'ar': 'انشر وظيفة'},
    'topServices': {'en': 'Top services', 'fr': 'Meilleurs services', 'ar': 'أفضل الخدمات'},
    'beginner': {'en': 'Beginner', 'fr': 'Débutant', 'ar': 'مبتدئ'},
    'intermediate': {'en': 'Intermediate', 'fr': 'Intermédiaire', 'ar': 'متوسط'},
    'advanced': {'en': 'Advanced', 'fr': 'Avancé', 'ar': 'متقدم'},
    'deliveryDays': {'en': 'days delivery', 'fr': 'jours de livraison', 'ar': 'أيام للتسليم'},
    'price': {'en': 'Price', 'fr': 'Prix', 'ar': 'السعر'},
    'enrollFree': {'en': 'Enroll — Free', 'fr': 'S’inscrire — Gratuit', 'ar': 'سجّل — مجاني'},
    'buy': {'en': 'Buy', 'fr': 'Acheter', 'ar': 'اشترِ'},
    'createAccount': {'en': 'Create account', 'fr': 'Créer un compte', 'ar': 'إنشاء حساب'},
    'getStarted': {'en': 'Start Learning — Free', 'fr': 'Commencer — Gratuit', 'ar': 'ابدأ التعلم — مجاناً'},
    'alreadyHaveAccount': {
      'en': 'Already have an account?',
      'fr': 'Vous avez déjà un compte ?',
      'ar': 'لديك حساب بالفعل؟',
    },
    'tagline': {
      'en': 'Your integrated\ntech ecosystem',
      'fr': 'Votre écosystème\ntech intégré',
      'ar': 'نظامك التقني\nالمتكامل',
    },
    'heroSubtitle': {
      'en': 'Learn, create, and connect in one professional space.',
      'fr': 'Apprenez, créez et connectez-vous dans un seul espace pro.',
      'ar': 'تعلّم، أنشئ، وتواصل في مساحة مهنية واحدة.',
    },
    'learnerRole': {'en': "I'm a Learner", 'fr': 'Je suis apprenant', 'ar': 'أنا طالب'},
    'teacherRole': {
      'en': "I'm a Teacher / Freelancer",
      'fr': 'Je suis enseignant / freelance',
      'ar': 'أنا معلم / مستقل',
    },
    'clientRole': {
      'en': "I'm a Client",
      'fr': 'Je cherche un prestataire',
      'ar': 'أنا أبحث عن من ينجز مشروعي',
    },
    'learnerDesc': {
      'en': 'Explore free & premium courses. Track progress and earn achievements.',
      'fr': 'Explorez des cours gratuits et premium. Suivez vos progrès.',
      'ar': 'استكشف دروس البرمجة والتصميم واحصل على شهادات معتمدة.',
    },
    'teacherDesc': {
      'en': 'Publish courses, offer mentoring, sell services, build your portfolio.',
      'fr': 'Publiez des cours, du mentoring, des services et votre portfolio.',
      'ar': 'شارك خبرتك، أنشئ دورات، ابنِ معرض أعمالك وتواصل مع العملاء.',
    },
    'clientDesc': {
      'en': 'Post projects, browse freelancers, request quotes and hire talent.',
      'fr': 'Publiez des projets, parcourez les freelances et recrutez.',
      'ar': 'اعرض فكرتك على المستقلين، احصل على عروض تنافسية وابنِ مشروعك.',
    },
    'startAsCreator': {
      'en': 'Start as creator',
      'fr': 'Commencer comme créateur',
      'ar': 'ابدأ مسارك كمعلم / مستقل',
    },
    'postProject': {
      'en': 'Post your project',
      'fr': 'Publier votre projet',
      'ar': 'اعرض مشروعك الآن',
    },
    'projectVisual': {
      'en': 'Visual identity for a startup',
      'fr': 'Identité visuelle pour une startup',
      'ar': 'هوية بصرية لشركة ناشئة',
    },
    'projectAndroid': {
      'en': 'Simple Android app',
      'fr': 'Application Android simple',
      'ar': 'تطبيق Android بسيط',
    },
    'graphicDesigner': {
      'en': 'Graphic designer',
      'fr': 'Designer graphique',
      'ar': 'مصمم جرافيك',
    },
    'fullstackDev': {
      'en': 'Full-stack developer',
      'fr': 'Développeur full-stack',
      'ar': 'مطور كامل المكدس',
    },
    'uiuxDesigner': {
      'en': 'UI/UX designer',
      'fr': 'Designer UI/UX',
      'ar': 'مصمم واجهات',
    },
    'editProfile': {'en': 'Edit', 'fr': 'Modifier', 'ar': 'تعديل'},
    'moments': {'en': 'Moments', 'fr': 'Moments', 'ar': 'لحظات'},
    'vipBenefits': {'en': 'VIP benefits', 'fr': 'Avantages VIP', 'ar': 'مزايا VIP'},
    'viewFeedback': {'en': 'View Feedback', 'fr': 'Voir les retours', 'ar': 'عرض التعليقات'},
    'insightBanner': {
      'en': 'Impressive! Your recent Portfolio case study received {n} high-quality views from recruiters.',
      'fr': 'Impressionnant ! Votre étude de cas a reçu {n} vues de qualité de recruteurs.',
      'ar': 'رائع! حصلت دراسة معرض أعمالك على {n} مشاهدة عالية الجودة من مسؤولي التوظيف.',
    },
    'exploreMasterclasses': {
      'en': 'Explore All Masterclasses',
      'fr': 'Explorer tous les masterclass',
      'ar': 'استكشف كل الدورات المتقدمة',
    },
    'learnHubTitle': {
      'en': 'Learn! Full Stack & Design Hub is here!',
      'fr': 'Apprenez ! Le hub Full Stack & Design est là !',
      'ar': 'تعلّم! مركز التطوير والتصميم هنا!',
    },
    'masterclassAccess': {
      'en': 'Masterclass Access',
      'fr': 'Accès Masterclass',
      'ar': 'الوصول للدورات المتقدمة',
    },
    'sourceFiles': {
      'en': 'Access to Source Design Files',
      'fr': 'Fichiers sources design',
      'ar': 'ملفات التصميم المصدرية',
    },
    'priorityReview': {
      'en': 'Priority Portfolio Review',
      'fr': 'Revue portfolio prioritaire',
      'ar': 'مراجعة أولوية للمعرض',
    },
    'webinars': {
      'en': 'Exclusive Industry Webinars',
      'fr': 'Webinaires exclusifs',
      'ar': 'ندوات حصرية',
    },
    'freeCol': {'en': 'Free', 'fr': 'Gratuit', 'ar': 'مجاني'},
    'premiumCol': {'en': 'Premium', 'fr': 'Premium', 'ar': 'مميز'},
    'unlimitedMaster': {
      'en': 'Unlimited Masterclasses',
      'fr': 'Masterclass illimités',
      'ar': 'دورات غير محدودة',
    },
    'freePrompts': {
      'en': '5 curated design prompts/day',
      'fr': '5 prompts design / jour',
      'ar': '5 مطالبات تصميم يومياً',
    },
    'defaultBio': {
      'en': 'Learner | Software & Design',
      'fr': 'Apprenant | Dev & Design',
      'ar': 'طالب | برمجة وتصميم',
    },
    'eduGames': {
      'en': 'Edu Games',
      'fr': 'Jeux éducatifs',
      'ar': 'ألعاب تعليمية',
    },
    'eduGamesSub': {
      'en': 'Play short coding & design challenges. Score 60%+ to earn coins (once per day).',
      'fr': 'Défis code & design. 60%+ pour gagner des pièces (1× / jour).',
      'ar': 'تحديات برمجة وتصميم قصيرة. احصل على عملات عند 60٪+ (مرة يومياً).',
    },
    'aiTokens': {'en': 'AI tokens', 'fr': 'Jetons IA', 'ar': 'رموز الذكاء'},
    'freeToday': {'en': 'Free today', 'fr': 'Gratuit aujourd’hui', 'ar': 'مجاني اليوم'},
    'bonusTokens': {'en': 'Bonus', 'fr': 'Bonus', 'ar': 'مكافأة'},
    'aiUnlockHint': {
      'en': 'Finish lessons & games to earn coins, then unlock more AI messages.',
      'fr': 'Terminez cours & jeux pour gagner des pièces, puis débloquez plus d’IA.',
      'ar': 'أكمل الدروس والألعاب لكسب عملات وفتح المزيد من رسائل الذكاء الاصطناعي.',
    },
    'openAi': {'en': 'Open AI', 'fr': 'Ouvrir l’IA', 'ar': 'فتح الذكاء'},
    'unlockTokens': {'en': 'Unlock tokens', 'fr': 'Débloquer', 'ar': 'فتح الرموز'},
    'aiPackSmall': {
      'en': 'Spark pack · +5 tokens',
      'fr': 'Pack étincelle · +5 jetons',
      'ar': 'باقة شرارة · +5 رموز',
    },
    'aiPackLarge': {
      'en': 'Boost pack · +15 tokens',
      'fr': 'Pack boost · +15 jetons',
      'ar': 'باقة دفع · +15 رمزاً',
    },
    'bestValue': {'en': 'Best value', 'fr': 'Meilleure offre', 'ar': 'الأفضل قيمة'},
    'notEnoughCoins': {
      'en': 'Not enough coins — play a game or finish a lesson!',
      'fr': 'Pas assez de pièces — jouez ou terminez une leçon !',
      'ar': 'عملات غير كافية — العب أو أكمل درساً!',
    },
    'tokensUnlocked': {
      'en': '+{n} AI tokens unlocked!',
      'fr': '+{n} jetons IA débloqués !',
      'ar': 'تم فتح {n} رمزاً!',
    },
    'seeAll': {'en': 'See all', 'fr': 'Tout voir', 'ar': 'عرض الكل'},
    'filterAll': {'en': 'All', 'fr': 'Tous', 'ar': 'الكل'},
    'filterPremium': {'en': 'Premium', 'fr': 'Premium', 'ar': 'مدفوع'},
    'lessonRewardHint': {
      'en': 'Complete lessons to earn +15 coins & XP. Finish a course for a bonus.',
      'fr': 'Terminez une leçon : +15 pièces & XP. Bonus en fin de cours.',
      'ar': 'أكمل درساً: +15 عملة وXP. مكافأة عند إنهاء الدورة.',
    },
    'completeLesson': {
      'en': 'Mark complete · earn coins',
      'fr': 'Terminer · gagner des pièces',
      'ar': 'إكمال · اربح عملات',
    },
    'lessonDone': {'en': 'Completed', 'fr': 'Terminé', 'ar': 'مكتمل'},
    'earnRewards': {'en': 'Earn rewards', 'fr': 'Gagner', 'ar': 'اربح'},
    'rewardSnack': {
      'en': '+{c} coins · +{x} XP',
      'fr': '+{c} pièces · +{x} XP',
      'ar': '+{c} عملة · +{x} XP',
    },
    'checkout': {'en': 'Checkout', 'fr': 'Paiement', 'ar': 'الدفع'},
    'orderSummary': {'en': 'Order summary', 'fr': 'Récapitulatif', 'ar': 'ملخص الطلب'},
    'total': {'en': 'Total', 'fr': 'Total', 'ar': 'المجموع'},
    'paymentMethod': {
      'en': 'Payment method',
      'fr': 'Moyen de paiement',
      'ar': 'طريقة الدفع',
    },
    'mockPaymentNote': {
      'en': 'Demo only — no real charges. Edahabia & CIB screens are simulated.',
      'fr': 'Démo uniquement — aucun débit réel. Écrans Edahabia & CIB simulés.',
      'ar': 'تجريبي فقط — لا خصم حقيقي. شاشات الذهبية وCIB محاكاة.',
    },
    'selectPaymentMethod': {
      'en': 'Select a payment method',
      'fr': 'Choisir un moyen de paiement',
      'ar': 'اختر طريقة الدفع',
    },
    'continueToPay': {'en': 'Continue', 'fr': 'Continuer', 'ar': 'متابعة'},
    'paymentSuccess': {
      'en': 'Payment successful',
      'fr': 'Paiement réussi',
      'ar': 'تم الدفع بنجاح',
    },
    'paymentFailed': {
      'en': 'Payment failed',
      'fr': 'Échec du paiement',
      'ar': 'فشل الدفع',
    },
    'paymentSuccessCoins': {
      'en': 'Paid with Smooth Coins',
      'fr': 'Payé avec des pièces Smooth',
      'ar': 'تم الدفع بعملات سموث',
    },
    'mockGateway': {'en': 'Mock gateway', 'fr': 'Passerelle démo', 'ar': 'بوابة تجريبية'},
    'edahabiaSecure': {
      'en': 'Secure Edahabia payment · Algérie Poste',
      'fr': 'Paiement Edahabia sécurisé · Algérie Poste',
      'ar': 'دفع الذهبية الآمن · بريد الجزائر',
    },
    'merchant': {'en': 'Merchant', 'fr': 'Marchand', 'ar': 'التاجر'},
    'cardNumber': {'en': 'Card number', 'fr': 'N° de carte', 'ar': 'رقم البطاقة'},
    'cardHolder': {'en': 'Card holder', 'fr': 'Titulaire', 'ar': 'حامل البطاقة'},
    'expiry': {'en': 'Expiry', 'fr': 'Expiration', 'ar': 'الانتهاء'},
    'payNow': {'en': 'Pay now', 'fr': 'Payer', 'ar': 'ادفع الآن'},
    'confirmPayment': {'en': 'Confirm payment', 'fr': 'Confirmer le paiement', 'ar': 'تأكيد الدفع'},
    'otpHint': {
      'en': 'Enter the SMS OTP sent to your phone (demo: any 4+ digits except 0000).',
      'fr': 'Saisissez l’OTP SMS (démo : 4+ chiffres sauf 0000).',
      'ar': 'أدخل رمز OTP (تجريبي: أي 4 أرقام ما عدا 0000).',
    },
    'otpCode': {'en': 'OTP code', 'fr': 'Code OTP', 'ar': 'رمز OTP'},
    'enterOtp': {'en': 'Enter a valid OTP', 'fr': 'Saisissez un OTP valide', 'ar': 'أدخل رمزًا صالحًا'},
    'edahabiaDemoTip': {
      'en': 'Tip: use prefilled card · OTP 0000 simulates failure.',
      'fr': 'Astuce : carte préremplie · OTP 0000 = échec.',
      'ar': 'بطاقة معبأة مسبقاً · OTP 0000 يحاكي الفشل.',
    },
    'cibDemoTip': {
      'en': 'Demo CIB form — any values are accepted.',
      'fr': 'Formulaire CIB démo — toute saisie est acceptée.',
      'ar': 'نموذج CIB تجريبي — أي قيم مقبولة.',
    },
    'amountToPay': {'en': 'Amount to pay', 'fr': 'Montant à payer', 'ar': 'المبلغ المستحق'},
    'cardPayment': {'en': 'Card payment', 'fr': 'Paiement par carte', 'ar': 'الدفع بالبطاقة'},
    'order': {'en': 'Order', 'fr': 'Commande', 'ar': 'الطلب'},
    'gateway': {'en': 'Gateway', 'fr': 'Passerelle', 'ar': 'البوابة'},
    'amount': {'en': 'Amount', 'fr': 'Montant', 'ar': 'المبلغ'},
    'reference': {'en': 'Reference', 'fr': 'Référence', 'ar': 'المرجع'},
    'paidWithCoins': {'en': 'Coins', 'fr': 'Pièces', 'ar': 'عملات'},
    'backHome': {'en': 'Back to home', 'fr': 'Retour à l’accueil', 'ar': 'العودة للرئيسية'},
    'openCourse': {'en': 'Open course', 'fr': 'Ouvrir le cours', 'ar': 'فتح الدورة'},
    'bookNow': {'en': 'Book now', 'fr': 'Réserver', 'ar': 'احجز الآن'},
    'payWithEdahabia': {
      'en': 'Pay with Edahabia',
      'fr': 'Payer avec Edahabia',
      'ar': 'ادفع بالذهبية',
    },
    'payDzd': {'en': 'Pay in DZD', 'fr': 'Payer en DZD', 'ar': 'ادفع بالدينار'},
    'postCourse': {'en': 'Post a course', 'fr': 'Publier un cours', 'ar': 'نشر دورة'},
    'postService': {'en': 'Post a service', 'fr': 'Publier un service', 'ar': 'نشر خدمة'},
    'publishCourse': {'en': 'Publish course', 'fr': 'Publier le cours', 'ar': 'نشر الدورة'},
    'publishService': {'en': 'Publish service', 'fr': 'Publier le service', 'ar': 'نشر الخدمة'},
    'courseTitle': {'en': 'Course title', 'fr': 'Titre du cours', 'ar': 'عنوان الدورة'},
    'serviceTitle': {'en': 'Service title', 'fr': 'Titre du service', 'ar': 'عنوان الخدمة'},
    'description': {'en': 'Description', 'fr': 'Description', 'ar': 'الوصف'},
    'difficulty': {'en': 'Difficulty', 'fr': 'Niveau', 'ar': 'المستوى'},
    'fillRequired': {
      'en': 'Please fill title and description',
      'fr': 'Remplissez le titre et la description',
      'ar': 'املأ العنوان والوصف',
    },
    'creatorEarnHint': {
      'en': 'Earn coins by posting courses/services, getting bookings, and claiming your daily rating bonus.',
      'fr': 'Gagnez des pièces en publiant, en recevant des clients et via le bonus notation quotidien.',
      'ar': 'اربح عملات بنشر الدورات/الخدمات، والحصول على حجوزات، ومكافأة التقييم اليومية.',
    },
    'myCourses': {'en': 'My courses', 'fr': 'Mes cours', 'ar': 'دوراتي'},
    'myServices': {'en': 'My services', 'fr': 'Mes services', 'ar': 'خدماتي'},
    'noCoursesYet': {'en': 'No courses yet', 'fr': 'Aucun cours', 'ar': 'لا دورات بعد'},
    'noServicesYet': {'en': 'No services yet', 'fr': 'Aucun service', 'ar': 'لا خدمات بعد'},
    'createFirstCourse': {
      'en': 'Create your first course and earn coins.',
      'fr': 'Créez votre premier cours et gagnez des pièces.',
      'ar': 'أنشئ دورتك الأولى واربح عملات.',
    },
    'createFirstService': {
      'en': 'Publish a freelance service to appear in the marketplace.',
      'fr': 'Publiez un service freelance pour apparaître sur le marché.',
      'ar': 'انشر خدمة مستقلة لتظهر في السوق.',
    },
    'newCourse': {'en': 'New course', 'fr': 'Nouveau cours', 'ar': 'دورة جديدة'},
    'newService': {'en': 'New service', 'fr': 'Nouveau service', 'ar': 'خدمة جديدة'},
    'claimRatingBonus': {
      'en': 'Claim rating bonus',
      'fr': 'Bonus notation',
      'ar': 'مكافأة التقييم',
    },
    'bonusAlreadyClaimed': {
      'en': 'Already claimed today',
      'fr': 'Déjà réclamé aujourd’hui',
      'ar': 'تم المطالبة اليوم',
    },
    'coursePostedReward': {
      'en': 'Course published! +{n} coins',
      'fr': 'Cours publié ! +{n} pièces',
      'ar': 'نُشرت الدورة! +{n} عملة',
    },
    'servicePostedReward': {
      'en': 'Service published! +{n} coins',
      'fr': 'Service publié ! +{n} pièces',
      'ar': 'نُشرت الخدمة! +{n} عملة',
    },
    'ratingBonusClaimed': {
      'en': '+{n} coins for great ratings!',
      'fr': '+{n} pièces pour vos bonnes notes !',
      'ar': '+{n} عملة لتقييماتك الجيدة!',
    },
    'creatorMarketTitle': {
      'en': 'Creator marketplace',
      'fr': 'Marché créateur',
      'ar': 'سوق المبدعين',
    },
    'clientMarketTitle': {
      'en': 'Hire talent on Smooth',
      'fr': 'Recrutez sur Smooth',
      'ar': 'وظّف المواهب على سموث',
    },
    'clientMarketSub': {
      'en': 'Browse freelancers, book services, or post a job.',
      'fr': 'Parcourez les freelances, réservez ou publiez une mission.',
      'ar': 'تصفح المستقلين، احجز خدمات، أو انشر وظيفة.',
    },
    'hireTalent': {'en': 'Hire talent', 'fr': 'Recruter', 'ar': 'توظيف'},
    'myListings': {'en': 'My listings', 'fr': 'Mes annonces', 'ar': 'إعلاناتي'},
    'jobOffers': {'en': 'Job offers', 'fr': 'Offres d’emploi', 'ar': 'عروض العمل'},
    'applyJobsHint': {
      'en': 'Apply to gigs that match your skills.',
      'fr': 'Postulez aux missions qui matchent vos skills.',
      'ar': 'قدّم على الفرص المناسبة لمهاراتك.',
    },
    'clientRequests': {
      'en': 'Client project requests',
      'fr': 'Demandes clients',
      'ar': 'طلبات مشاريع العملاء',
    },
    'creatorActions': {
      'en': 'Grow your studio',
      'fr': 'Développez votre studio',
      'ar': 'طوّر استوديوكم',
    },
    'browseJobs': {'en': 'Browse jobs', 'fr': 'Voir les jobs', 'ar': 'تصفح الوظائف'},
    'creatorStudio': {
      'en': 'Creator Studio',
      'fr': 'Studio créateur',
      'ar': 'استوديو المبدع',
    },
    'teacherHeroTitle': {
      'en': 'Teach. Freelancer. Earn coins.',
      'fr': 'Enseignez. Freelancez. Gagnez.',
      'ar': 'علّم. قدّم خدمات. اربح عملات.',
    },
    'teacherHeroSubtitle': {
      'en': 'Publish courses, offer services, apply to jobs — grow your studio on Smooth Hub.',
      'fr': 'Publiez des cours, des services, postulez — développez votre studio sur Smooth Hub.',
      'ar': 'انشر دورات وخدمات وقدّم على وظائف — طوّر استوديوكم على سموث هب.',
    },
    'tryDemoAccounts': {
      'en': 'Try a demo account',
      'fr': 'Essayer un compte démo',
      'ar': 'جرّب حساباً تجريبياً',
    },
    'demoTapLogin': {
      'en': 'Tap to sign in instantly',
      'fr': 'Appuyez pour vous connecter',
      'ar': 'اضغط لتسجيل الدخول فوراً',
    },
    'demoLearnerLabel': {
      'en': 'Learner demo',
      'fr': 'Démo apprenant',
      'ar': 'حساب طالب تجريبي',
    },
    'demoTeacherLabel': {
      'en': 'Teacher / Freelancer demo',
      'fr': 'Démo enseignant / freelance',
      'ar': 'حساب معلم / مستقل تجريبي',
    },
    'demoClientLabel': {
      'en': 'Client demo',
      'fr': 'Démo client',
      'ar': 'حساب عميل تجريبي',
    },
  };
}

class SDelegate extends LocalizationsDelegate<S> {
  const SDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async => S(locale);

  @override
  bool shouldReload(SDelegate old) => false;
}
