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

/// Lightweight translations for Samooth (FR / AR / EN).
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
  String get opportunities => t('opportunities');
  String get opportunitiesSub => t('opportunitiesSub');
  String get profile => t('profile');
  String get dashboard => t('dashboard');
  String get courses => t('courses');
  String get services => t('services');
  String get language => t('language');
  String get welcome => t('welcome');
  String onboardingWelcomeName(String name) => t('onboardingWelcomeName').replaceAll('{name}', name);
  String get onboardingWelcome => t('onboardingWelcome');
  String get onboardingSubtitle => t('onboardingSubtitle');
  String get onboardingSkip => t('onboardingSkip');
  String get onboardingNext => t('onboardingNext');
  String get onboardingStart => t('onboardingStart');
  String get onboardingLearner1Title => t('onboardingLearner1Title');
  String get onboardingLearner1Body => t('onboardingLearner1Body');
  String get onboardingLearner2Title => t('onboardingLearner2Title');
  String get onboardingLearner2Body => t('onboardingLearner2Body');
  String get onboardingLearner3Title => t('onboardingLearner3Title');
  String get onboardingLearner3Body => t('onboardingLearner3Body');
  String get onboardingLearner4Title => t('onboardingLearner4Title');
  String get onboardingLearner4Body => t('onboardingLearner4Body');
  String get onboardingTeacher1Title => t('onboardingTeacher1Title');
  String get onboardingTeacher1Body => t('onboardingTeacher1Body');
  String get onboardingTeacher2Title => t('onboardingTeacher2Title');
  String get onboardingTeacher2Body => t('onboardingTeacher2Body');
  String get onboardingTeacher3Title => t('onboardingTeacher3Title');
  String get onboardingTeacher3Body => t('onboardingTeacher3Body');
  String get onboardingTeacher4Title => t('onboardingTeacher4Title');
  String get onboardingTeacher4Body => t('onboardingTeacher4Body');
  String get onboardingClient1Title => t('onboardingClient1Title');
  String get onboardingClient1Body => t('onboardingClient1Body');
  String get onboardingClient2Title => t('onboardingClient2Title');
  String get onboardingClient2Body => t('onboardingClient2Body');
  String get onboardingClient3Title => t('onboardingClient3Title');
  String get onboardingClient3Body => t('onboardingClient3Body');
  String get onboardingClient4Title => t('onboardingClient4Title');
  String get onboardingClient4Body => t('onboardingClient4Body');
  String get onboardingAdmin1Title => t('onboardingAdmin1Title');
  String get onboardingAdmin1Body => t('onboardingAdmin1Body');
  String get onboardingAdmin2Title => t('onboardingAdmin2Title');
  String get onboardingAdmin2Body => t('onboardingAdmin2Body');
  String get onboardingAdmin3Title => t('onboardingAdmin3Title');
  String get onboardingAdmin3Body => t('onboardingAdmin3Body');
  String get onboardingAdmin4Title => t('onboardingAdmin4Title');
  String get onboardingAdmin4Body => t('onboardingAdmin4Body');
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
  String get aiAssistantName => t('aiAssistantName');
  String aiWelcome(String name) => t('aiWelcome').replaceAll('{name}', name);
  String get aiWelcomeGuest => t('aiWelcomeGuest');
  String get aiTyping => t('aiTyping');
  String get aiInputHint => t('aiInputHint');
  String get aiChipStudyPlan => t('aiChipStudyPlan');
  String get aiChipQuiz => t('aiChipQuiz');
  String get aiChipCoins => t('aiChipCoins');
  String get aiChipFlutter => t('aiChipFlutter');
  String get aiChipCareer => t('aiChipCareer');
  String get aiPromptStudyPlan => t('aiPromptStudyPlan');
  String get aiPromptQuiz => t('aiPromptQuiz');
  String get aiPromptCoins => t('aiPromptCoins');
  String get aiReplyFlutter => t('aiReplyFlutter');
  String get aiReplyDesign => t('aiReplyDesign');
  String get aiReplyCoins => t('aiReplyCoins');
  String get aiReplyStudyPlan => t('aiReplyStudyPlan');
  String get aiReplyQuiz => t('aiReplyQuiz');
  String get aiReplyCareer => t('aiReplyCareer');
  String get aiReplyDefault => t('aiReplyDefault');
  String get aiWelcomeCreator => t('aiWelcomeCreator');
  String aiWelcomeCreatorName(String name) => t('aiWelcomeCreatorName').replaceAll('{name}', name);
  String get aiChipCourseIdea => t('aiChipCourseIdea');
  String get aiChipPricing => t('aiChipPricing');
  String get aiChipMarketing => t('aiChipMarketing');
  String get aiChipPortfolio => t('aiChipPortfolio');
  String get aiPromptCourseIdea => t('aiPromptCourseIdea');
  String get aiPromptPricing => t('aiPromptPricing');
  String get aiPromptMarketing => t('aiPromptMarketing');
  String get aiPromptPortfolio => t('aiPromptPortfolio');
  String get aiReplyCourseIdea => t('aiReplyCourseIdea');
  String get aiReplyPricing => t('aiReplyPricing');
  String get aiReplyMarketing => t('aiReplyMarketing');
  String get aiReplyPortfolioTip => t('aiReplyPortfolioTip');
  String get aiReplyCreatorDefault => t('aiReplyCreatorDefault');
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
  String get splashTagline => t('splashTagline');
  String get splashSlogan => t('splashSlogan');
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
  String get subscriptionTypes => t('subscriptionTypes');
  String get subscriptionTypesHint => t('subscriptionTypesHint');
  String get planFree => t('planFree');
  String get planPremium => t('planPremium');
  String get planVip => t('planVip');
  String get planFreePrice => t('planFreePrice');
  String get planPremiumPrice => t('planPremiumPrice');
  String get planVipPrice => t('planVipPrice');
  String get planPopular => t('planPopular');
  String get planBestValue => t('planBestValue');
  String get planVipPerk => t('planVipPerk');
  String activatePlan(String plan) => t('activatePlan').replaceAll('{plan}', plan);
  String planActivated(String plan) => t('planActivated').replaceAll('{plan}', plan);
  String currentPlanLabel(String plan) => t('currentPlanLabel').replaceAll('{plan}', plan);
  String get currentPlanBadge => t('currentPlanBadge');
  String get currentPlanActive => t('currentPlanActive');
  String get subscriptionCheckoutSubtitle => t('subscriptionCheckoutSubtitle');
  String masterclassLimitReached(int limit) => t('masterclassLimitReached').replaceAll('{limit}', '$limit');
  String get upgradeSubscription => t('upgradeSubscription');
  String get subscriptionCoversCourses => t('subscriptionCoversCourses');
  String get enrollIncluded => t('enrollIncluded');
  String get downloadSourceFiles => t('downloadSourceFiles');
  String get sourceFilesLocked => t('sourceFilesLocked');
  String get sourceFilesDownloaded => t('sourceFilesDownloaded');
  String get exclusiveWebinarsTitle => t('exclusiveWebinarsTitle');
  String get exclusiveWebinarsBody => t('exclusiveWebinarsBody');
  String get vipMentoringTitle => t('vipMentoringTitle');
  String get vipMentoringBody => t('vipMentoringBody');
  String get priorityReviewActive => t('priorityReviewActive');
  String get viewFeedback => t('viewFeedback');
  String get feedbackTitle => t('feedbackTitle');
  String get feedbackSubtitle => t('feedbackSubtitle');
  String get feedbackRecent => t('feedbackRecent');
  String get averageRating => t('averageRating');
  String reviewsCount(int n) => t('reviewsCount').replaceAll('{n}', '$n');
  String feedbackOn(String context) => t('feedbackOn').replaceAll('{context}', context);
  String feedbackDaysAgo(int n) => t('feedbackDaysAgo').replaceAll('{n}', '$n');
  String feedbackWeeksAgo(int n) => t('feedbackWeeksAgo').replaceAll('{n}', '$n');
  String get feedbackPortfolioCase => t('feedbackPortfolioCase');
  String get feedbackExTeacher1 => t('feedbackExTeacher1');
  String get feedbackExTeacher2 => t('feedbackExTeacher2');
  String get feedbackExTeacher3 => t('feedbackExTeacher3');
  String get feedbackExTeacher4 => t('feedbackExTeacher4');
  String get feedbackExLearner1 => t('feedbackExLearner1');
  String get feedbackExLearner2 => t('feedbackExLearner2');
  String get feedbackExLearner3 => t('feedbackExLearner3');
  String get feedbackExLearner4 => t('feedbackExLearner4');
  String get feedbackExClient1 => t('feedbackExClient1');
  String get feedbackExClient2 => t('feedbackExClient2');
  String get feedbackExClient3 => t('feedbackExClient3');
  String get feedbackExAdmin1 => t('feedbackExAdmin1');
  String get feedbackExAdmin2 => t('feedbackExAdmin2');
  String get feedbackExAdmin3 => t('feedbackExAdmin3');
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
  String get learnMentorsTitle => t('learnMentorsTitle');
  String get learnMentorsSub => t('learnMentorsSub');
  String get viewProfile => t('viewProfile');
  String get contactProvider => t('contactProvider');
  String contactProviderSubject(String name) => t('contactProviderSubject').replaceAll('{name}', name);
  String get leaveReview => t('leaveReview');
  String get yourRating => t('yourRating');
  String get reviewComment => t('reviewComment');
  String get submitReview => t('submitReview');
  String get reviewSubmitted => t('reviewSubmitted');
  String get availableCourses => t('availableCourses');
  String get profileLibraryTitle => t('profileLibraryTitle');
  String get myLearning => t('myLearning');
  String get clientLibraryTitle => t('clientLibraryTitle');
  String get learningJourney => t('learningJourney');
  String get learningJourneySub => t('learningJourneySub');
  String get clientShowcaseTitle => t('clientShowcaseTitle');
  String get clientShowcaseSub => t('clientShowcaseSub');
  String get bookedServicesLabel => t('bookedServicesLabel');
  String get noEnrolledCourses => t('noEnrolledCourses');
  String get noBookedServices => t('noBookedServices');
  String get noReviewsYet => t('noReviewsYet');
  String get myStudents => t('myStudents');
  String get enrolledStudents => t('enrolledStudents');
  String totalEnrolled(int n) => t('totalEnrolled').replaceAll('{n}', '$n');
  String studentsEnrolled(int n) => t('studentsEnrolled').replaceAll('{n}', '$n');
  String get studentProgress => t('studentProgress');
  String get noEnrolledStudentsYet => t('noEnrolledStudentsYet');
  String get courseStudents => t('courseStudents');
  String get publicationKindOffer => t('publicationKindOffer');
  String get publicationKindAnnouncement => t('publicationKindAnnouncement');
  String get momentsSubtitle => t('momentsSubtitle');
  String get momentsEmptyHint => t('momentsEmptyHint');
  String get writeAReview => t('writeAReview');
  String get reviewCommentHint => t('reviewCommentHint');
  String reviewsLabel(int n) => t('reviewsLabel').replaceAll('{n}', '$n');
  String get requestQuote => t('requestQuote');
  String get courseNotFound => t('courseNotFound');
  String get serviceNotFound => t('serviceNotFound');
  String get enrolledSuccess => t('enrolledSuccess');
  String get curriculum => t('curriculum');
  String get quoteSentDemo => t('quoteSentDemo');
  String get signInRequired => t('signInRequired');
  String get manageCourse => t('manageCourse');
  String get manageCoursesTab => t('manageCoursesTab');
  String get manageStudentsTab => t('manageStudentsTab');
  String get faqTitle => t('faqTitle');
  String get faqRevisionsQ => t('faqRevisionsQ');
  String get faqRevisionsA => t('faqRevisionsA');
  String get providerReviewMaria1 => t('providerReviewMaria1');
  String get providerReviewMaria2 => t('providerReviewMaria2');
  String get providerReviewMaria3 => t('providerReviewMaria3');
  String get providerReviewJames1 => t('providerReviewJames1');
  String get providerReviewJames2 => t('providerReviewJames2');
  String get providerReviewSarah1 => t('providerReviewSarah1');
  String get providerReviewSarah2 => t('providerReviewSarah2');
  String get providerReviewAlex1 => t('providerReviewAlex1');
  String get providerReviewAlex2 => t('providerReviewAlex2');
  String get providerReviewEmma1 => t('providerReviewEmma1');
  String get providerReviewDefault => t('providerReviewDefault');
  String get filterAll => t('filterAll');
  String get filterPremium => t('filterPremium');
  String get lessonRewardHint => t('lessonRewardHint');
  String get completeLesson => t('completeLesson');
  String get lessonDone => t('lessonDone');
  String get earnRewards => t('earnRewards');
  String get notifications => t('notifications');
  String get privacySecurity => t('privacySecurity');
  String get appearance => t('appearance');
  String get helpSupport => t('helpSupport');
  String get aboutApp => t('aboutApp');
  String get shareApp => t('shareApp');
  String get shareWithOthers => t('shareWithOthers');
  String get copyLink => t('copyLink');
  String get linkCopied => t('linkCopied');

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
  String get courseMedia => t('courseMedia');
  String get courseMediaHint => t('courseMediaHint');
  String get addCoverImage => t('addCoverImage');
  String get addIntroVideo => t('addIntroVideo');
  String get coverImageAdded => t('coverImageAdded');
  String get introVideoAdded => t('introVideoAdded');
  String get removeMedia => t('removeMedia');
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
  String get postuler => t('postuler');
  String get applicationSent => t('applicationSent');
  String get alreadyApplied => t('alreadyApplied');
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
  String get demoAdminLabel => t('demoAdminLabel');
  String get adminRole => t('adminRole');
  String get adminDesc => t('adminDesc');
  String get openAdminPanel => t('openAdminPanel');

  String get adminPanel => t('adminPanel');
  String get adminWelcome => t('adminWelcome');
  String get adminHeroTitle => t('adminHeroTitle');
  String get adminHeroSubtitle => t('adminHeroSubtitle');
  String get adminAnalytics => t('adminAnalytics');
  String get adminQuickActions => t('adminQuickActions');
  String get users => t('users');
  String get hub => t('hub');
  String get reports => t('reports');
  String get teachers => t('teachers');
  String get bookings => t('bookings');
  String get learners => t('learners');
  String get clients => t('clients');
  String get messages => t('messages');
  String get rooms => t('rooms');
  String get printOrders => t('printOrders');
  String get escrowDeals => t('escrowDeals');
  String get escrowCompletedDeals => t('escrowCompletedDeals');
  String get platformRevenue => t('platformRevenue');
  String get escrowTracking => t('escrowTracking');
  String escrowTrackingSummary(int fundedCount, String feesTotal) =>
      t('escrowTrackingSummary').replaceAll('{count}', '$fundedCount').replaceAll('{fees}', feesTotal);
  String get paymentPurposeEscrow => t('paymentPurposeEscrow');
  String get paymentPurposeEscrowRelease => t('paymentPurposeEscrowRelease');
  String get manageUsers => t('manageUsers');
  String get manageUsersSub => t('manageUsersSub');
  String get manageReports => t('manageReports');
  String get manageReportsSub => t('manageReportsSub');
  String get manageMarketplace => t('manageMarketplace');
  String get manageMarketplaceSub => t('manageMarketplaceSub');
  String get manageRooms => t('manageRooms');
  String get manageRoomsSub => t('manageRoomsSub');
  String get managePrint => t('managePrint');
  String get managePrintSub => t('managePrintSub');
  String get manageLogs => t('manageLogs');
  String get manageLogsSub => t('manageLogsSub');
  String get paymentLogs => t('paymentLogs');
  String get activityLogs => t('activityLogs');
  String get noPaymentLogs => t('noPaymentLogs');
  String get noActivityLogs => t('noActivityLogs');
  String get markDone => t('markDone');
  String get anonymousUser => t('anonymousUser');
  String get system => t('system');
  String get manageMessages => t('manageMessages');
  String get manageMessagesSub => t('manageMessagesSub');
  String get howUsersContact => t('howUsersContact');
  String get contactInfo => t('contactInfo');
  String get settings => t('settings');
  String get noReports => t('noReports');
  String get reported => t('reported');
  String get reporter => t('reporter');
  String get resolve => t('resolve');
  String get dismiss => t('dismiss');
  String get noBookings => t('noBookings');
  String get capacity => t('capacity');
  String get roomBookings => t('roomBookings');
  String get printCatalog => t('printCatalog');
  String get noOrders => t('noOrders');
  String get noMessages => t('noMessages');
  String get hubFacilities => t('hubFacilities');
  String get hubFacilitiesSub => t('hubFacilitiesSub');
  String get rentRooms => t('rentRooms');
  String get rentRoomsSub => t('rentRoomsSub');
  String get printingServices => t('printingServices');
  String get printingServicesSub => t('printingServicesSub');
  String get contactHub => t('contactHub');
  String get contactHubSub => t('contactHubSub');
  String get available => t('available');
  String get unavailable => t('unavailable');
  String get bookHours => t('bookHours');
  String get bookDay => t('bookDay');
  String get roomBooked => t('roomBooked');
  String get printOrdered => t('printOrdered');
  String get subject => t('subject');
  String get message => t('message');
  String get sendMessage => t('sendMessage');
  String get messageSent => t('messageSent');
  String get directMessages => t('directMessages');
  String get directMessage => t('directMessage');
  String get hubSupport => t('hubSupport');
  String get startConversation => t('startConversation');
  String get sendOffer => t('sendOffer');
  String get offerTitle => t('offerTitle');
  String get offerDescription => t('offerDescription');
  String get offerAmount => t('offerAmount');
  String get payEscrow => t('payEscrow');
  String get markDelivered => t('markDelivered');
  String get approveRelease => t('approveRelease');
  String approveReleaseConfirm(String amount) => t('approveReleaseConfirm').replaceAll('{amount}', amount);
  String get escrowReleased => t('escrowReleased');
  String get escrowOffer => t('escrowOffer');
  String get escrowPending => t('escrowPending');
  String get escrowFunded => t('escrowFunded');
  String get escrowDelivered => t('escrowDelivered');
  String get escrowCompleted => t('escrowCompleted');
  String get escrowCancelled => t('escrowCancelled');
  String get escrowPaySubtitle => t('escrowPaySubtitle');
  String escrowFeeNote(String fee) => t('escrowFeeNote').replaceAll('{fee}', fee);
  String escrowPayoutSummary(String payout, String fee) =>
      t('escrowPayoutSummary').replaceAll('{payout}', payout).replaceAll('{fee}', fee);
  String get backToConversation => t('backToConversation');
  String get myMessages => t('myMessages');
  String get myMessagesSub => t('myMessagesSub');
  String get composeMessage => t('composeMessage');
  String get backToMenu => t('backToMenu');
  String get switchRole => t('switchRole');
  String get portfolio => t('portfolio');
  String get previousWork => t('previousWork');
  String get publications => t('publications');
  String get noPublications => t('noPublications');
  String get newPublication => t('newPublication');
  String get announcements => t('announcements');
  String get hashtags => t('hashtags');
  String get hashtagsHint => t('hashtagsHint');
  String get publish => t('publish');
  String get replyViaEmail => t('replyViaEmail');
  String get contactHubWelcome => t('contactHubWelcome');
  String get typeYourMessage => t('typeYourMessage');
  String get today => t('today');
  String get reportUser => t('reportUser');
  String get reportUserSub => t('reportUserSub');
  String get reason => t('reason');
  String get details => t('details');
  String get submitReport => t('submitReport');
  String get reportSent => t('reportSent');
  String get allUsers => t('allUsers');
  String get noUsersInCategory => t('noUsersInCategory');
  String get editUser => t('editUser');
  String get displayName => t('displayName');
  String get bio => t('bio');
  String get cancel => t('cancel');
  String get save => t('save');
  String get delete => t('delete');
  String get deleteUser => t('deleteUser');
  String get deleteUserConfirm => t('deleteUserConfirm');
  String get userUpdated => t('userUpdated');
  String get userDeleted => t('userDeleted');
  String get blockUser => t('blockUser');
  String get unlockUser => t('unlockUser');
  String get userBlocked => t('userBlocked');
  String get userUnlocked => t('userUnlocked');
  String get adminHubRedirect => t('adminHubRedirect');
  String get searchUserToReport => t('searchUserToReport');
  String get searchUserHint => t('searchUserHint');
  String get noUsersFound => t('noUsersFound');
  String get userNotFound => t('userNotFound');

  static const _strings = <String, Map<String, String>>{
    'appName': {'en': 'Samooth', 'fr': 'Samooth', 'ar': 'ساموث'},
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
    'opportunities': {
      'en': 'Opportunities',
      'fr': 'Opportunités',
      'ar': 'الفرص',
    },
    'opportunitiesSub': {
      'en': 'Missions, freelance gigs & project briefs',
      'fr': 'Missions, gigs freelance & appels à projets',
      'ar': 'مهام ومشاريع وفرص عمل حرة',
    },
    'profile': {'en': 'Profile', 'fr': 'Profil', 'ar': 'حسابي'},
    'dashboard': {'en': 'Dashboard', 'fr': 'Tableau', 'ar': 'لوحة التحكم'},
    'courses': {'en': 'Courses', 'fr': 'Cours', 'ar': 'الدورات'},
    'services': {'en': 'Services', 'fr': 'Services', 'ar': 'الخدمات'},
    'language': {'en': 'Language', 'fr': 'Langue', 'ar': 'اللغة'},
    'welcome': {'en': 'Welcome!', 'fr': 'Bienvenue !', 'ar': 'أهلاً بك!'},
    'onboardingWelcomeName': {
      'en': 'Welcome, {name}!',
      'fr': 'Bienvenue, {name} !',
      'ar': 'مرحبا بيك {name}!',
    },
    'onboardingWelcome': {
      'en': 'Welcome to Samooth!',
      'fr': 'Bienvenue sur Samooth !',
      'ar': 'مرحبا بيك ف Samooth!',
    },
    'onboardingSubtitle': {
      'en': 'A quick tour — shown only once.',
      'fr': 'Petit tour rapide — affiché une seule fois.',
      'ar': 'جولة سريعة — تبان ليك مرة وحدة بس.',
    },
    'onboardingSkip': {'en': 'Skip', 'fr': 'Passer', 'ar': 'تخطى'},
    'onboardingNext': {'en': 'Next', 'fr': 'Suivant', 'ar': 'التالي'},
    'onboardingStart': {'en': "Let's go", 'fr': "C'est parti", 'ar': 'يلا نبدأ'},
    'onboardingLearner1Title': {
      'en': 'Learn for free',
      'fr': 'Apprendre gratuitement',
      'ar': 'تعلّم ببلاش',
    },
    'onboardingLearner1Body': {
      'en': 'Open the Learn tab to browse courses, videos, and mini-games.',
      'fr': 'Onglet Apprendre : cours, vidéos et mini-jeux.',
      'ar': 'روح لتبويب التعلّم: دورات، فيديوهات وألعاب تعليمية.',
    },
    'onboardingLearner2Title': {
      'en': 'Marketplace',
      'fr': 'Marché',
      'ar': 'السوق',
    },
    'onboardingLearner2Body': {
      'en': 'Find freelancers and premium content when you need extra help.',
      'fr': 'Trouvez des freelances et du contenu premium.',
      'ar': 'لقى فريلانسرز ومحتوى مميز إذا تحتاج مساعدة.',
    },
    'onboardingLearner3Title': {
      'en': 'AI assistant',
      'fr': 'Assistant IA',
      'ar': 'المساعد الذكي',
    },
    'onboardingLearner3Body': {
      'en': 'Ask what to study next or get quick explanations anytime.',
      'fr': 'Demandez quoi étudier ou une explication rapide.',
      'ar': 'اسألو شنو تدرس بعد أو يشرحلك بسرعة.',
    },
    'onboardingLearner4Title': {
      'en': 'Your profile',
      'fr': 'Votre profil',
      'ar': 'البروفايل تاعك',
    },
    'onboardingLearner4Body': {
      'en': 'Track streak, XP, and settings from the Profile tab.',
      'fr': 'Suivez série, XP et réglages dans Profil.',
      'ar': 'تابع السلسلة، النقاط والإعدادات من البروفايل.',
    },
    'onboardingTeacher1Title': {
      'en': 'Your dashboard',
      'fr': 'Votre tableau',
      'ar': 'لوحة التحكم',
    },
    'onboardingTeacher1Body': {
      'en': 'See enrollments, earnings, and quick actions at a glance.',
      'fr': 'Inscriptions, revenus et actions rapides en un coup d’œil.',
      'ar': 'شوف التسجيلات، الأرباح والإجراءات السريعة.',
    },
    'onboardingTeacher2Title': {
      'en': 'Publish courses',
      'fr': 'Publier des cours',
      'ar': 'انشر دوراتك',
    },
    'onboardingTeacher2Body': {
      'en': 'Create a course with cover image and intro video from Courses.',
      'fr': 'Créez un cours avec image et vidéo d’intro.',
      'ar': 'أنشئ دورة بصورة غلاف وفيديو تمهيدي.',
    },
    'onboardingTeacher3Title': {
      'en': 'Hub facilities',
      'fr': 'Services du Hub',
      'ar': 'خدمات الهب',
    },
    'onboardingTeacher3Body': {
      'en': 'Book rooms and order printing from the Hub tab.',
      'fr': 'Réservez des salles et l’impression via Hub.',
      'ar': 'احجز قاعات واطلب طباعة من تبويب الهب.',
    },
    'onboardingTeacher4Title': {
      'en': 'Opportunities',
      'fr': 'Opportunités',
      'ar': 'الفرص',
    },
    'onboardingTeacher4Body': {
      'en': 'Browse missions and freelance gigs in Opportunities.',
      'fr': 'Parcourez missions et gigs freelance.',
      'ar': 'تصفّح المهام والفرص فتبويب الفرص.',
    },
    'onboardingClient1Title': {
      'en': 'Hire talent',
      'fr': 'Recruter',
      'ar': 'وظّف مواهب',
    },
    'onboardingClient1Body': {
      'en': 'Browse services and freelancer profiles on the Market.',
      'fr': 'Parcourez services et profils sur le Marché.',
      'ar': 'تصفّح الخدمات والبروفايلات فالسوق.',
    },
    'onboardingClient2Title': {
      'en': 'Hub booking',
      'fr': 'Réservation Hub',
      'ar': 'حجز الهب',
    },
    'onboardingClient2Body': {
      'en': 'Rent meeting rooms or request print jobs at the Hub.',
      'fr': 'Louez des salles ou demandez une impression.',
      'ar': 'كري قاعات أو اطلب خدمة طباعة.',
    },
    'onboardingClient3Title': {
      'en': 'Post projects',
      'fr': 'Publier un projet',
      'ar': 'انشر مشاريع',
    },
    'onboardingClient3Body': {
      'en': 'Share briefs and find freelancers in Opportunities.',
      'fr': 'Partagez des briefs dans Opportunités.',
      'ar': 'حط briefs وتلقى فريلانسرز فالفرص.',
    },
    'onboardingClient4Title': {
      'en': 'Keep learning',
      'fr': 'Continuer à apprendre',
      'ar': 'واصل التعلّم',
    },
    'onboardingClient4Body': {
      'en': 'Upskill with free courses in the Learn tab.',
      'fr': 'Montez en compétences via Apprendre.',
      'ar': 'طوّر مهاراتك بالدورات المجانية.',
    },
    'onboardingAdmin1Title': {
      'en': 'Dashboard',
      'fr': 'Tableau de bord',
      'ar': 'لوحة الإدارة',
    },
    'onboardingAdmin1Body': {
      'en': 'Overview of users, bookings, and platform activity.',
      'fr': 'Vue d’ensemble : utilisateurs, réservations, activité.',
      'ar': 'نظرة عامة على المستخدمين والحجوزات والنشاط.',
    },
    'onboardingAdmin2Title': {
      'en': 'User management',
      'fr': 'Gestion utilisateurs',
      'ar': 'إدارة المستخدمين',
    },
    'onboardingAdmin2Body': {
      'en': 'Edit, block, or remove accounts by role.',
      'fr': 'Modifier, bloquer ou supprimer par rôle.',
      'ar': 'عدّل، احظر أو احذف الحسابات حسب النوع.',
    },
    'onboardingAdmin3Title': {
      'en': 'Reports',
      'fr': 'Signalements',
      'ar': 'البلاغات',
    },
    'onboardingAdmin3Body': {
      'en': 'Review and resolve user reports.',
      'fr': 'Examinez et traitez les signalements.',
      'ar': 'راجع وعالج البلاغات.',
    },
    'onboardingAdmin4Title': {
      'en': 'Messages',
      'fr': 'Messages',
      'ar': 'الرسائل',
    },
    'onboardingAdmin4Body': {
      'en': 'Reply to contact requests from the inbox.',
      'fr': 'Répondez aux demandes de contact.',
      'ar': 'جاوب على رسائل التواصل.',
    },
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
      'en': 'Samooth Hub: Your Integrated Tech Ecosystem',
      'fr': 'Samooth Hub : votre écosystème tech intégré',
      'ar': 'ساموث هب: نظامك التقني المتكامل',
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
    'aiAssistantName': {'en': 'Samooth AI', 'fr': 'Samooth IA', 'ar': 'ساموث AI'},
    'aiWelcome': {
      'en': 'Hi {name}! I can help you pick a learning path, explain concepts, quiz you, or suggest what to study next.',
      'fr': 'Salut {name} ! Je peux t’aider à choisir un parcours, expliquer un concept, te faire un quiz ou te dire quoi étudier.',
      'ar': 'مرحباً {name}! أستطيع مساعدتك في اختيار مسار، شرح مفاهيم، اختبارك، أو اقتراح ما تدرسه.',
    },
    'aiWelcomeGuest': {
      'en': 'Hi! I can help you pick a learning path, explain concepts, quiz you, or suggest what to study next.',
      'fr': 'Salut ! Je peux t’aider à choisir un parcours, expliquer un concept, te faire un quiz ou te dire quoi étudier.',
      'ar': 'مرحباً! أستطيع مساعدتك في اختيار مسار، شرح مفاهيم، اختبارك، أو اقتراح ما تدرسه.',
    },
    'aiTyping': {
      'en': 'Samooth AI is thinking…',
      'fr': 'Samooth IA réfléchit…',
      'ar': 'ساموث AI يفكر…',
    },
    'aiInputHint': {
      'en': 'Ask anything about learning…',
      'fr': 'Posez une question sur l’apprentissage…',
      'ar': 'اسأل عن التعلم…',
    },
    'aiChipStudyPlan': {'en': 'Study plan', 'fr': 'Plan d’étude', 'ar': 'خطة دراسة'},
    'aiChipQuiz': {'en': 'Quiz me', 'fr': 'Fais-moi un quiz', 'ar': 'اختبرني'},
    'aiChipCoins': {'en': 'Earn coins?', 'fr': 'Gagner des pièces ?', 'ar': 'كيف أربح عملات؟'},
    'aiChipFlutter': {'en': 'Flutter tips', 'fr': 'Conseils Flutter', 'ar': 'نصائح Flutter'},
    'aiChipCareer': {'en': 'Career advice', 'fr': 'Conseil carrière', 'ar': 'نصيحة مهنية'},
    'aiPromptStudyPlan': {
      'en': 'Create a 7-day study plan for me',
      'fr': 'Crée-moi un plan d’étude sur 7 jours',
      'ar': 'أنشئ لي خطة دراسة لمدة 7 أيام',
    },
    'aiPromptQuiz': {
      'en': 'Generate a quick quiz on programming basics',
      'fr': 'Génère un quiz rapide sur les bases de la programmation',
      'ar': 'أنشئ اختباراً سريعاً على أساسيات البرمجة',
    },
    'aiPromptCoins': {
      'en': 'How do I earn coins and AI tokens?',
      'fr': 'Comment gagner des pièces et des jetons IA ?',
      'ar': 'كيف أربح عملات ورموز الذكاء الاصطناعي؟',
    },
    'aiReplyFlutter': {
      'en': 'Start with Dart basics (variables, functions, classes), then build a small Flutter app with navigation and Riverpod. Practice 30 minutes daily and complete Programming Essentials on Samooth.',
      'fr': 'Commence par les bases Dart (variables, fonctions, classes), puis une petite app Flutter avec navigation et Riverpod. 30 min/jour et termine Programming Essentials sur Samooth.',
      'ar': 'ابدأ بأساسيات Dart ثم تطبيق Flutter صغير مع التنقل وRiverpod. 30 دقيقة يومياً وأكمل Programming Essentials على Samooth.',
    },
    'aiReplyDesign': {
      'en': 'Focus on typography, spacing, and layout grids first. Redesign one app screen per day in Figma, then compare with Material 3 guidelines.',
      'fr': 'Commence par typo, espacements et grilles. Refais un écran par jour dans Figma, puis compare avec Material 3.',
      'ar': 'ركّز على الخطوط والمسافات والشبكات. أعد تصميم شاشة يومياً في Figma وقارنها بإرشادات Material 3.',
    },
    'aiReplyCoins': {
      'en': 'Complete lessons (+15 coins), finish courses for bonuses, play Edu Games at 60%+ once per day, or claim your daily creator rating bonus if you teach.',
      'fr': 'Termine des leçons (+15 pièces), finis un cours pour un bonus, joue aux Edu Games à 60%+ (1×/jour), ou réclame le bonus créateur si tu enseignes.',
      'ar': 'أكمل الدروس (+15 عملة)، أنهِ دورة للمكافأة، العب Edu Games بنسبة 60٪+ مرة يومياً، أو اطلب مكافأة المبدع إن كنت معلماً.',
    },
    'aiReplyStudyPlan': {
      'en': 'Here’s a 7-day plan:\n• Day 1–2: Dart syntax & widgets\n• Day 3–4: Navigation + state\n• Day 5: API call demo\n• Day 6: Mini project polish\n• Day 7: Review + quiz\nWant me to adapt it to mobile or design?',
      'fr': 'Plan sur 7 jours :\n• J1–2 : syntaxe Dart & widgets\n• J3–4 : navigation + état\n• J5 : appel API\n• J6 : mini-projet\n• J7 : révision + quiz\nOn l’adapte mobile ou design ?',
      'ar': 'خطة 7 أيام:\n• يوم 1–2: Dart والويدجتات\n• يوم 3–4: التنقل والحالة\n• يوم 5: استدعاء API\n• يوم 6: مشروع صغير\n• يوم 7: مراجعة + اختبار\nتريدها للموبايل أم التصميم؟',
    },
    'aiReplyQuiz': {
      'en': 'Quick quiz:\n1. What is a Widget in Flutter?\n2. Difference between StatelessWidget and StatefulWidget?\n3. What does `async/await` do?\nReply with your answers and I’ll correct you!',
      'fr': 'Quiz rapide :\n1. Qu’est-ce qu’un Widget Flutter ?\n2. Différence Stateless vs Stateful ?\n3. À quoi sert `async/await` ?\nRéponds et je corrige !',
      'ar': 'اختبار سريع:\n1. ما هو Widget في Flutter؟\n2. الفرق بين StatelessWidget وStatefulWidget؟\n3. ماذا يفعل async/await؟\nأجب وسأصحح لك!',
    },
    'aiReplyCareer': {
      'en': 'Build a visible portfolio on Samooth: 1 course completed, 1 mini project, and a marketplace service or case study. Recruiters on the hub look for consistent progress and clear deliverables.',
      'fr': 'Construis un portfolio visible sur Samooth : 1 cours terminé, 1 mini-projet, et un service ou cas d’étude sur le marché. Les recruteurs regardent la régularité et les livrables.',
      'ar': 'ابنِ معرض أعمال على Samooth: دورة مكتملة، مشروع صغير، وخدمة أو دراسة حالة في السوق. المسؤولون يبحثون عن تقدم منتظم ومخرجات واضحة.',
    },
    'aiReplyDefault': {
      'en': 'Based on your goals, pick one skill area and complete a beginner course this week. Ask me for a study plan, a quiz, or tips on Flutter, design, or earning coins.',
      'fr': 'Selon tes objectifs, choisis un domaine et termine un cours débutant cette semaine. Demande un plan, un quiz ou des conseils Flutter, design ou pièces.',
      'ar': 'حسب أهدافك، اختر مجالاً وأكمل دورة مبتدئة هذا الأسبوع. اطلب خطة دراسة أو اختباراً أو نصائح Flutter أو التصميم أو العملات.',
    },
    'aiWelcomeCreator': {
      'en': 'Hi! I can help you plan courses, price your services, write marketing copy, or improve your portfolio.',
      'fr': 'Salut ! Je peux t’aider à planifier des cours, fixer tes tarifs, rédiger du contenu marketing, ou améliorer ton portfolio.',
      'ar': 'مرحباً! أستطيع مساعدتك في تخطيط الدورات، تسعير خدماتك، كتابة محتوى تسويقي، أو تحسين معرض أعمالك.',
    },
    'aiWelcomeCreatorName': {
      'en': 'Hi {name}! I can help you plan courses, price your services, write marketing copy, or improve your portfolio.',
      'fr': 'Salut {name} ! Je peux t’aider à planifier des cours, fixer tes tarifs, rédiger du contenu marketing, ou améliorer ton portfolio.',
      'ar': 'مرحباً {name}! أستطيع مساعدتك في تخطيط الدورات، تسعير خدماتك، كتابة محتوى تسويقي، أو تحسين معرض أعمالك.',
    },
    'aiChipCourseIdea': {'en': 'Course idea', 'fr': 'Idée de cours', 'ar': 'فكرة دورة'},
    'aiChipPricing': {'en': 'Pricing help', 'fr': 'Aide tarifs', 'ar': 'مساعدة تسعير'},
    'aiChipMarketing': {'en': 'Marketing copy', 'fr': 'Texte marketing', 'ar': 'نص تسويقي'},
    'aiChipPortfolio': {'en': 'Portfolio tips', 'fr': 'Conseils portfolio', 'ar': 'نصائح للمعرض'},
    'aiPromptCourseIdea': {
      'en': 'Suggest a course idea based on my skills',
      'fr': 'Suggère une idée de cours selon mes compétences',
      'ar': 'اقترح فكرة دورة حسب مهاراتي',
    },
    'aiPromptPricing': {
      'en': 'How should I price my service?',
      'fr': 'Comment fixer le prix de mon service ?',
      'ar': 'كيف أسعّر خدمتي؟',
    },
    'aiPromptMarketing': {
      'en': 'Write a short promo post for my service',
      'fr': 'Rédige un court post promo pour mon service',
      'ar': 'اكتب منشوراً ترويجياً قصيراً لخدمتي',
    },
    'aiPromptPortfolio': {
      'en': 'How can I improve my portfolio?',
      'fr': 'Comment améliorer mon portfolio ?',
      'ar': 'كيف أحسّن معرض أعمالي؟',
    },
    'aiReplyCourseIdea': {
      'en': 'Look at what students are asking about in your niche, then package it as a short, focused course (3–5 lessons). Beginner-friendly + one hands-on project converts best.',
      'fr': 'Repère ce que les apprenants demandent dans ta niche, puis crée un cours court et ciblé (3–5 leçons). Niveau débutant + un projet pratique convertit le mieux.',
      'ar': 'راقب ما يسأل عنه المتعلمون في مجالك، ثم صمم دورة قصيرة ومركزة (3-5 دروس). مستوى مبتدئ مع مشروع عملي يحقق أفضل إقبال.',
    },
    'aiReplyPricing': {
      'en': 'Check 3 similar listings on Samooth, price near the middle, and offer a lower "starter" tier. Raise prices once you have 5+ reviews above 4.5★.',
      'fr': 'Compare 3 annonces similaires sur Samooth, place-toi au milieu, et propose un tarif "starter" plus bas. Augmente une fois 5+ avis au-dessus de 4.5★.',
      'ar': 'قارن 3 إعلانات مشابهة على Samooth، سعّر في المنتصف، وقدّم باقة "بداية" أرخص. ارفع السعر بعد 5 تقييمات فما فوق بـ4.5★.',
    },
    'aiReplyMarketing': {
      'en': '"Need [skill] done right? I help clients on Samooth Hub deliver [result] in [timeframe]. Book a session today." Keep it under 3 lines and add one concrete result.',
      'fr': '« Besoin de [compétence] bien fait ? J’aide les clients sur Samooth Hub à obtenir [résultat] en [délai]. Réservez dès aujourd’hui. » Reste sous 3 lignes avec un résultat concret.',
      'ar': '"تحتاج [مهارة] بإتقان؟ أساعد العملاء على Samooth Hub في تحقيق [نتيجة] خلال [مدة]. احجز اليوم." اجعله أقل من 3 أسطر مع نتيجة ملموسة.',
    },
    'aiReplyPortfolioTip': {
      'en': 'Lead with your best 2 pieces, add a one-line result for each ("+30% signups"), and keep captions short. Recruiters skim — make the first 3 seconds count.',
      'fr': 'Mets tes 2 meilleures réalisations en avant, ajoute un résultat en une ligne pour chacune, et garde les légendes courtes. Les recruteurs survolent — les 3 premières secondes comptent.',
      'ar': 'ابدأ بأفضل عملين، أضف نتيجة بسطر واحد لكل منهما، واجعل الأوصاف قصيرة. المسؤولون يتصفحون بسرعة — اجعل أول 3 ثوانٍ مؤثرة.',
    },
    'aiReplyCreatorDefault': {
      'en': 'Tell me if you want help with a course idea, pricing, marketing copy, or your portfolio — I can tailor advice to what you\'re building.',
      'fr': 'Dis-moi si tu veux de l\'aide pour une idée de cours, un tarif, un texte marketing, ou ton portfolio — je peux adapter mes conseils.',
      'ar': 'أخبرني إن كنت تريد مساعدة بفكرة دورة، تسعير، نص تسويقي، أو معرض أعمالك — يمكنني تخصيص النصيحة.',
    },
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
      'en': 'Samooth Hub: Hire Talent. Ship Faster.',
      'fr': 'Samooth Hub : recrutez. Livrez plus vite.',
      'ar': 'ساموث هب: وظّف المواهب وأنجز أسرع',
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
    'splashTagline': {
      'en': 'LEARN & EARN | STEP BY STEP',
      'fr': 'APPRENDRE & GAGNER | PAS À PAS',
      'ar': 'تعلّم واربح | خطوة بخطوة',
    },
    'splashSlogan': {
      'en': 'YOUR JOURNEY TO DIGITAL MASTERY BEGINS HERE.',
      'fr': 'VOTRE PARCOURS VERS LA MAÎTRISE DIGITALE COMMENCE ICI.',
      'ar': 'رحلتك نحو الإتقان الرقمي تبدأ من هنا.',
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
    'subscriptionTypes': {
      'en': 'Subscription plans',
      'fr': 'Types d’abonnement',
      'ar': 'أنواع الاشتراك',
    },
    'subscriptionTypesHint': {
      'en': 'Tap a plan to compare and choose your bundle.',
      'fr': 'Choisissez votre formule en appuyant sur un forfait.',
      'ar': 'اختار الباقة اللي تناسبك بالضغط على أحد العروض.',
    },
    'planFree': {'en': 'Free', 'fr': 'Gratuit', 'ar': 'مجاني'},
    'planPremium': {'en': 'Premium', 'fr': 'Premium', 'ar': 'مميز'},
    'planVip': {'en': 'VIP', 'fr': 'VIP', 'ar': 'VIP'},
    'planFreePrice': {'en': '0 DZD', 'fr': '0 د.ج', 'ar': '0 د.ج'},
    'planPremiumPrice': {
      'en': '1,990 DZD / mo',
      'fr': '1 990 د.ج / mois',
      'ar': '1 990 د.ج / شهر',
    },
    'planVipPrice': {
      'en': '14,900 DZD / yr',
      'fr': '14 900 د.ج / an',
      'ar': '14 900 د.ج / سنة',
    },
    'planPopular': {'en': 'Popular', 'fr': 'Populaire', 'ar': 'الأكثر طلباً'},
    'planBestValue': {'en': 'Best value', 'fr': 'Meilleur prix', 'ar': 'أفضل قيمة'},
    'planVipPerk': {
      'en': '1-on-1 mentoring',
      'fr': 'Mentorat individuel',
      'ar': 'مرافقة فردية',
    },
    'activatePlan': {
      'en': 'Activate {plan}',
      'fr': 'Activer {plan}',
      'ar': 'تفعيل {plan}',
    },
    'planActivated': {
      'en': '{plan} plan activated (demo)',
      'fr': 'Formule {plan} activée (démo)',
      'ar': 'تم تفعيل باقة {plan} (تجريبي)',
    },
    'currentPlanLabel': {
      'en': 'Your plan: {plan}',
      'fr': 'Votre formule : {plan}',
      'ar': 'باقتك: {plan}',
    },
    'currentPlanBadge': {'en': 'Active', 'fr': 'Actif', 'ar': 'نشط'},
    'currentPlanActive': {'en': 'Current plan', 'fr': 'Formule actuelle', 'ar': 'الباقة الحالية'},
    'subscriptionCheckoutSubtitle': {
      'en': 'Monthly / yearly subscription',
      'fr': 'Abonnement mensuel / annuel',
      'ar': 'اشتراك شهري / سنوي',
    },
    'masterclassLimitReached': {
      'en': 'Free plan allows {limit} masterclasses. Upgrade for unlimited access.',
      'fr': 'La formule gratuite permet {limit} masterclasses. Passez à Premium pour un accès illimité.',
      'ar': 'الباقة المجانية تسمح بـ {limit} دورات. ترقّ للوصول غير المحدود.',
    },
    'upgradeSubscription': {'en': 'Upgrade', 'fr': 'Upgrader', 'ar': 'ترقية'},
    'subscriptionCoversCourses': {
      'en': 'Enrolled — included in your subscription',
      'fr': 'Inscrit — inclus dans votre abonnement',
      'ar': 'تم التسجيل — مشمول في اشتراكك',
    },
    'enrollIncluded': {
      'en': 'Enroll (included)',
      'fr': 'S\'inscrire (inclus)',
      'ar': 'التسجيل (مشمول)',
    },
    'downloadSourceFiles': {
      'en': 'Download source files',
      'fr': 'Télécharger les fichiers sources',
      'ar': 'تحميل ملفات المصدر',
    },
    'sourceFilesLocked': {
      'en': 'Source files — Premium or VIP required',
      'fr': 'Fichiers sources — Premium ou VIP requis',
      'ar': 'ملفات المصدر — Premium أو VIP مطلوب',
    },
    'sourceFilesDownloaded': {
      'en': 'Source files saved (demo)',
      'fr': 'Fichiers sources enregistrés (démo)',
      'ar': 'تم حفظ ملفات المصدر (تجريبي)',
    },
    'exclusiveWebinarsTitle': {
      'en': 'Exclusive webinars',
      'fr': 'Webinaires exclusifs',
      'ar': 'ندوات حصرية',
    },
    'exclusiveWebinarsBody': {
      'en': 'Live sessions with top mentors — included in your Premium/VIP plan.',
      'fr': 'Sessions live avec des mentors — incluses dans Premium/VIP.',
      'ar': 'جلسات مباشرة مع مرشدين — مشمولة في Premium/VIP.',
    },
    'vipMentoringTitle': {
      'en': '1-on-1 mentoring',
      'fr': 'Mentorat individuel',
      'ar': 'مرافقة فردية',
    },
    'vipMentoringBody': {
      'en': 'Book a private session with a Samooth mentor (VIP).',
      'fr': 'Réservez une session privée avec un mentor Samooth (VIP).',
      'ar': 'احجز جلسة خاصة مع مرشد Samooth (VIP).',
    },
    'priorityReviewActive': {
      'en': 'Priority portfolio review active',
      'fr': 'Revue portfolio prioritaire active',
      'ar': 'مراجعة معرض أعمال بأولوية',
    },
    'viewFeedback': {'en': 'View Feedback', 'fr': 'Voir les retours', 'ar': 'عرض التعليقات'},
    'feedbackTitle': {'en': 'Feedback', 'fr': 'Retours', 'ar': 'التعليقات'},
    'feedbackSubtitle': {
      'en': 'Recent reviews from learners, clients and recruiters.',
      'fr': 'Derniers avis d’apprenants, clients et recruteurs.',
      'ar': 'آخر آراء المتعلمين والعملاء ومسؤولي التوظيف.',
    },
    'feedbackRecent': {'en': 'Recent reviews', 'fr': 'Avis récents', 'ar': 'آراء حديثة'},
    'averageRating': {'en': 'Average rating', 'fr': 'Note moyenne', 'ar': 'متوسط التقييم'},
    'reviewsCount': {'en': '{n} reviews', 'fr': '{n} avis', 'ar': '{n} تقييم'},
    'feedbackOn': {'en': 'On {context}', 'fr': 'Sur {context}', 'ar': 'حول {context}'},
    'feedbackDaysAgo': {'en': '{n}d ago', 'fr': 'Il y a {n} j', 'ar': 'منذ {n} ي'},
    'feedbackWeeksAgo': {'en': '{n}w ago', 'fr': 'Il y a {n} sem', 'ar': 'منذ {n} أ'},
    'feedbackPortfolioCase': {
      'en': 'Portfolio case study',
      'fr': 'Étude de cas portfolio',
      'ar': 'دراسة معرض الأعمال',
    },
    'feedbackExTeacher1': {
      'en': 'Excellent Flutter course — very clear and well structured. My students loved it!',
      'fr': 'Formation Flutter excellente, très claire et bien structurée. Mes élèves ont adoré !',
      'ar': 'دورة فلاتر ممتازة، واضحة ومنظمة. تلاميذي أحبوها!',
    },
    'feedbackExTeacher2': {
      'en': 'Studio A session was perfect. Great equipment and smooth booking.',
      'fr': 'Session Studio A parfaite. Bon équipement et réservation fluide.',
      'ar': 'جلسة الاستوديو A ممتازة. معدات جيدة وحجز سلس.',
    },
    'feedbackExTeacher3': {
      'en': 'Good support on the marketplace listing. Delivered on time.',
      'fr': 'Bon accompagnement sur l’annonce marketplace. Livraison dans les délais.',
      'ar': 'دعم جيد على إعلان السوق. التسليم في الوقت المحدد.',
    },
    'feedbackExTeacher4': {
      'en': 'Professional and patient teacher. I finally understood state management.',
      'fr': 'Professeur pro et patient. J’ai enfin compris la gestion d’état.',
      'ar': 'أستاذ محترف وصبور. فهمت أخيراً إدارة الحالة.',
    },
    'feedbackExLearner1': {
      'en': 'Strong portfolio — solid UI skills and clean case study presentation.',
      'fr': 'Portfolio solide — bonnes compétences UI et présentation claire du cas.',
      'ar': 'معرض أعمال قوي — مهارات واجهة جيدة وعرض واضح.',
    },
    'feedbackExLearner2': {
      'en': 'Impressive React Native project. Would recommend for junior mobile roles.',
      'fr': 'Projet React Native impressionnant. Je recommande pour des postes junior mobile.',
      'ar': 'مشروع React Native مميز. أنصح به لمناصب الموبايل المبتدئة.',
    },
    'feedbackExLearner3': {
      'en': 'Interesting UI portfolio — good eye for layout and typography.',
      'fr': 'Portfolio UI intéressant — bon sens du layout et de la typo.',
      'ar': 'معرض واجهات مثير — حس جيد للتخطيط والخطوط.',
    },
    'feedbackExLearner4': {
      'en': 'Great peer feedback on the group project. Very collaborative.',
      'fr': 'Super retour en peer review sur le projet de groupe. Très collaboratif.',
      'ar': 'ملاحظات رائعة من الأقران على المشروع الجماعي.',
    },
    'feedbackExClient1': {
      'en': 'Clear brief, fast delivery and great communication throughout.',
      'fr': 'Brief clair, livraison rapide et excellente communication.',
      'ar': 'ملخص واضح، تسليم سريع وتواصل ممتاز.',
    },
    'feedbackExClient2': {
      'en': 'Brand refresh exceeded expectations. The team understood our vision.',
      'fr': 'Refonte de marque au-delà de nos attentes. L’équipe a compris notre vision.',
      'ar': 'تجديد الهوية فاق التوقعات. الفريق فهم رؤيتنا.',
    },
    'feedbackExClient3': {
      'en': 'SEO campaign brought real traffic. Detailed monthly reports.',
      'fr': 'Campagne SEO avec du vrai trafic. Rapports mensuels détaillés.',
      'ar': 'حملة SEO جلبت زيارات حقيقية. تقارير شهرية مفصلة.',
    },
    'feedbackExAdmin1': {
      'en': 'Hub team is responsive. Room booking and support were seamless.',
      'fr': 'Équipe hub réactive. Réservation de salle et support sans accroc.',
      'ar': 'فريق الهب متجاوب. حجز القاعة والدعم كان سلساً.',
    },
    'feedbackExAdmin2': {
      'en': 'Print quality is excellent for our event flyers.',
      'fr': 'Qualité d’impression excellente pour nos flyers événement.',
      'ar': 'جودة طباعة ممتازة لمنشورات فعاليتنا.',
    },
    'feedbackExAdmin3': {
      'en': 'Easy room rental process. Perfect for weekly workshops.',
      'fr': 'Location de salle simple. Parfait pour nos ateliers hebdo.',
      'ar': 'عملية تأجير القاعة سهلة. مثالية لورشاتنا الأسبوعية.',
    },
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
    'learnMentorsTitle': {
      'en': 'Teachers & freelancers',
      'fr': 'Enseignants & freelances',
      'ar': 'الأساتذة والفريلانسرز',
    },
    'learnMentorsSub': {
      'en': 'Browse profiles, ratings and reviews from top creators.',
      'fr': 'Parcourez profils, notes et retours des meilleurs créateurs.',
      'ar': 'تصفّح البروفايلات، التقييمات والآراء لأفضل المنشئين.',
    },
    'viewProfile': {'en': 'View profile', 'fr': 'Voir le profil', 'ar': 'عرض البروفايل'},
    'contactProvider': {'en': 'Contact', 'fr': 'Contacter', 'ar': 'تواصل'},
    'contactProviderSubject': {
      'en': 'Message for {name}',
      'fr': 'Message pour {name}',
      'ar': 'رسالة إلى {name}',
    },
    'leaveReview': {'en': 'Leave a review', 'fr': 'Laisser un avis', 'ar': 'اترك تقييم'},
    'yourRating': {'en': 'Your rating', 'fr': 'Votre note', 'ar': 'تقييمك'},
    'reviewComment': {'en': 'Your feedback', 'fr': 'Votre retour', 'ar': 'رأيك'},
    'submitReview': {'en': 'Submit review', 'fr': 'Publier l’avis', 'ar': 'نشر التقييم'},
    'reviewSubmitted': {
      'en': 'Thank you! Your review was posted.',
      'fr': 'Merci ! Votre avis a été publié.',
      'ar': 'شكراً! تم نشر تقييمك.',
    },
    'availableCourses': {
      'en': 'Available courses',
      'fr': 'Cours disponibles',
      'ar': 'الدورات المتاحة',
    },
    'profileLibraryTitle': {
      'en': 'My courses & services',
      'fr': 'Mes cours & services',
      'ar': 'دوراتي وخدماتي',
    },
    'myLearning': {
      'en': 'My learning',
      'fr': 'Mon apprentissage',
      'ar': 'تعلّمي',
    },
    'clientLibraryTitle': {
      'en': 'Booked services',
      'fr': 'Services réservés',
      'ar': 'الخدمات المحجوزة',
    },
    'learningJourney': {
      'en': 'Learning journey',
      'fr': 'Parcours d\'apprentissage',
      'ar': 'مسار التعلّم',
    },
    'learningJourneySub': {
      'en': 'Courses, progress and moments',
      'fr': 'Cours, progression et moments',
      'ar': 'الدورات والتقدّم واللحظات',
    },
    'clientShowcaseTitle': {
      'en': 'Projects & activity',
      'fr': 'Projets & activité',
      'ar': 'المشاريع والنشاط',
    },
    'clientShowcaseSub': {
      'en': 'Offers, bookings and updates',
      'fr': 'Offres, réservations et actualités',
      'ar': 'العروض والحجوزات والتحديثات',
    },
    'bookedServicesLabel': {
      'en': 'Booked services',
      'fr': 'Services réservés',
      'ar': 'خدمات محجوزة',
    },
    'noEnrolledCourses': {
      'en': 'You have not enrolled in any courses yet.',
      'fr': 'Vous n’êtes inscrit à aucun cours pour le moment.',
      'ar': 'لم تسجّل في أي دورة بعد.',
    },
    'noBookedServices': {
      'en': 'You have not booked any services yet.',
      'fr': 'Vous n’avez réservé aucun service pour le moment.',
      'ar': 'لم تحجز أي خدمة بعد.',
    },
    'noReviewsYet': {
      'en': 'No reviews yet',
      'fr': 'Aucun avis pour le moment',
      'ar': 'لا توجد تقييمات بعد',
    },
    'myStudents': {
      'en': 'My students',
      'fr': 'Mes étudiants',
      'ar': 'طلابي',
    },
    'enrolledStudents': {
      'en': 'Enrolled students',
      'fr': 'Étudiants inscrits',
      'ar': 'الطلاب المسجلون',
    },
    'totalEnrolled': {
      'en': '{n} students enrolled',
      'fr': '{n} étudiants inscrits',
      'ar': '{n} طالب مسجل',
    },
    'studentsEnrolled': {
      'en': '{n} enrolled in this course',
      'fr': '{n} inscrits à ce cours',
      'ar': '{n} مسجل في هذه الدورة',
    },
    'studentProgress': {
      'en': 'Progress',
      'fr': 'Progression',
      'ar': 'التقدم',
    },
    'noEnrolledStudentsYet': {
      'en': 'No students enrolled yet. Share your course to get learners!',
      'fr': 'Aucun étudiant inscrit. Partagez votre cours !',
      'ar': 'لا يوجد طلاب مسجلون بعد. شارك دورتك!',
    },
    'courseStudents': {
      'en': 'Course & students',
      'fr': 'Cours & étudiants',
      'ar': 'الدورة والطلاب',
    },
    'publicationKindOffer': {
      'en': 'Offer',
      'fr': 'Offre',
      'ar': 'عرض',
    },
    'publicationKindAnnouncement': {
      'en': 'Announcement',
      'fr': 'Annonce',
      'ar': 'إعلان',
    },
    'momentsSubtitle': {
      'en': 'Posts, updates and highlights from this profile.',
      'fr': 'Publications, actualités et temps forts de ce profil.',
      'ar': 'منشورات وتحديثات وأبرز لحظات هذا البروفايل.',
    },
    'momentsEmptyHint': {
      'en': 'Share what you are working on — projects, tips, or announcements.',
      'fr': 'Partagez vos projets, conseils ou annonces.',
      'ar': 'شارك ما تعمل عليه — مشاريع، نصائح أو إعلانات.',
    },
    'writeAReview': {
      'en': 'Write a review',
      'fr': 'Rédiger un avis',
      'ar': 'اكتب تقييماً',
    },
    'reviewCommentHint': {
      'en': 'Share your experience with this creator…',
      'fr': 'Partagez votre expérience avec ce créateur…',
      'ar': 'شارك تجربتك مع هذا المنشئ…',
    },
    'reviewsLabel': {
      'en': '{n} reviews',
      'fr': '{n} avis',
      'ar': '{n} تقييم',
    },
    'requestQuote': {
      'en': 'Request quote',
      'fr': 'Demander un devis',
      'ar': 'طلب عرض سعر',
    },
    'courseNotFound': {
      'en': 'Course not found',
      'fr': 'Cours introuvable',
      'ar': 'الدورة غير موجودة',
    },
    'serviceNotFound': {
      'en': 'Service not found',
      'fr': 'Service introuvable',
      'ar': 'الخدمة غير موجودة',
    },
    'enrolledSuccess': {
      'en': 'Enrolled successfully!',
      'fr': 'Inscription réussie !',
      'ar': 'تم التسجيل بنجاح!',
    },
    'curriculum': {
      'en': 'Curriculum',
      'fr': 'Programme',
      'ar': 'المنهج',
    },
    'quoteSentDemo': {
      'en': 'Quote request sent (demo)',
      'fr': 'Demande de devis envoyée (démo)',
      'ar': 'تم إرسال طلب العرض (تجريبي)',
    },
    'signInRequired': {
      'en': 'Please sign in to continue',
      'fr': 'Connectez-vous pour continuer',
      'ar': 'يرجى تسجيل الدخول للمتابعة',
    },
    'manageCourse': {
      'en': 'Manage students',
      'fr': 'Gérer les étudiants',
      'ar': 'إدارة الطلاب',
    },
    'manageCoursesTab': {
      'en': 'Courses',
      'fr': 'Cours',
      'ar': 'الدورات',
    },
    'manageStudentsTab': {
      'en': 'Students',
      'fr': 'Étudiants',
      'ar': 'الطلاب',
    },
    'faqTitle': {
      'en': 'FAQ',
      'fr': 'FAQ',
      'ar': 'الأسئلة الشائعة',
    },
    'faqRevisionsQ': {
      'en': 'How many revisions?',
      'fr': 'Combien de révisions ?',
      'ar': 'كم عدد المراجعات؟',
    },
    'faqRevisionsA': {
      'en': 'Up to 3 revisions included.',
      'fr': 'Jusqu’à 3 révisions incluses.',
      'ar': 'حتى 3 مراجعات مشمولة.',
    },
    'providerReviewMaria1': {
      'en': 'Maria explains complex topics clearly. My Flutter skills jumped in weeks.',
      'fr': 'Maria explique clairement. Mes compétences Flutter ont progressé vite.',
      'ar': 'ماريا تشرح بوضوح. مهاراتي فـ Flutter تطورت بسرعة.',
    },
    'providerReviewMaria2': {
      'en': 'Great mentor — patient, structured, and always helpful on Slack.',
      'fr': 'Super mentor — patiente, structurée et toujours disponible.',
      'ar': 'مرافقة ممتازة — صبورة ومنظمة ودايماً متاحة.',
    },
    'providerReviewMaria3': {
      'en': 'Delivered a polished landing page ahead of schedule.',
      'fr': 'Landing page livrée avant la date, très pro.',
      'ar': 'سلّمت صفحة هبوط احترافية قبل الموعد.',
    },
    'providerReviewJames1': {
      'en': 'James transformed our app UI — clean, modern, and user-friendly.',
      'fr': 'James a transformé notre UI — moderne et intuitive.',
      'ar': 'جيمس غيّر واجهة التطبيق — عصرية وسهلة الاستعمال.',
    },
    'providerReviewJames2': {
      'en': 'Strong design system thinking. Would hire again.',
      'fr': 'Excellent sens du design system. Je referais appel à lui.',
      'ar': 'فهم قوي لنظام التصميم. نتعاون مرة أخرى بكل تأكيد.',
    },
    'providerReviewSarah1': {
      'en': 'Sarah’s marketing course helped me land my first clients.',
      'fr': 'Le cours marketing de Sarah m’a aidée à trouver mes premiers clients.',
      'ar': 'دورة سارة فالتسويق ساعدتني نلقى أول زبائن.',
    },
    'providerReviewSarah2': {
      'en': 'Practical SEO tips I applied the same week.',
      'fr': 'Conseils SEO pratiques appliqués la même semaine.',
      'ar': 'نصائح SEO عملية طبّقتهم نفس الأسبوع.',
    },
    'providerReviewAlex1': {
      'en': 'Alex made cybersecurity approachable for beginners.',
      'fr': 'Alex rend la cybersécurité accessible aux débutants.',
      'ar': 'أليكس خلّى الأمن السيبراني سهل للمبتدئين.',
    },
    'providerReviewAlex2': {
      'en': 'Thorough audit report with actionable fixes.',
      'fr': 'Audit détaillé avec corrections concrètes.',
      'ar': 'تقرير تدقيق مفصّل مع حلول واضحة.',
    },
    'providerReviewEmma1': {
      'en': 'Emma helped me structure my freelance business plan.',
      'fr': 'Emma m’a aidé à structurer mon plan freelance.',
      'ar': 'إيما ساعدتني ننظم خطة العمل الحرّة تاعي.',
    },
    'providerReviewDefault': {
      'en': 'Great experience — professional, responsive, and skilled.',
      'fr': 'Excellente expérience — pro, réactif et compétent.',
      'ar': 'تجربة ممتازة — محترف ومتجاوب وعنده مهارة.',
    },
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
      'en': 'Paid with Samooth Coins',
      'fr': 'Payé avec des pièces Samooth',
      'ar': 'تم الدفع بعملات ساموث',
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
    'courseMedia': {'en': 'Course media', 'fr': 'Médias du cours', 'ar': 'وسائط الدورة'},
    'courseMediaHint': {
      'en': 'Optional cover image and intro video for your first lesson.',
      'fr': 'Image de couverture et vidéo d’intro optionnelles pour la première leçon.',
      'ar': 'صورة غلاف وفيديو تمهيدي اختياريان للدرس الأول.',
    },
    'addCoverImage': {'en': 'Add cover image', 'fr': 'Ajouter une image', 'ar': 'إضافة صورة غلاف'},
    'addIntroVideo': {'en': 'Add intro video', 'fr': 'Ajouter une vidéo', 'ar': 'إضافة فيديو تمهيدي'},
    'coverImageAdded': {'en': 'Cover image added', 'fr': 'Image ajoutée', 'ar': 'تمت إضافة الصورة'},
    'introVideoAdded': {'en': 'Intro video added', 'fr': 'Vidéo ajoutée', 'ar': 'تمت إضافة الفيديو'},
    'removeMedia': {'en': 'Remove', 'fr': 'Retirer', 'ar': 'إزالة'},
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
      'en': 'Hire talent on Samooth',
      'fr': 'Recrutez sur Samooth',
      'ar': 'وظّف المواهب على ساموث',
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
    'postuler': {'en': 'Apply', 'fr': 'Postuler', 'ar': 'تقدّم'},
    'applicationSent': {
      'en': 'Application sent!',
      'fr': 'Candidature envoyée !',
      'ar': 'تم إرسال التقديم!',
    },
    'alreadyApplied': {
      'en': 'Applied',
      'fr': 'Déjà postulé',
      'ar': 'تم التقديم',
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
      'en': 'Publish courses, offer services, apply to jobs — grow your studio on Samooth Hub.',
      'fr': 'Publiez des cours, des services, postulez — développez votre studio sur Samooth Hub.',
      'ar': 'انشر دورات وخدمات وقدّم على وظائف — طوّر استوديوكم على ساموث هب.',
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
    'demoAdminLabel': {
      'en': 'Admin demo',
      'fr': 'Démo admin',
      'ar': 'حساب مدير تجريبي',
    },
    'adminRole': {
      'en': 'Admin',
      'fr': 'Admin',
      'ar': 'مدير',
    },
    'adminDesc': {
      'en': 'Manage users, reports, rooms, print orders and platform analytics.',
      'fr': 'Gérez utilisateurs, signalements, salles, impressions et analytics.',
      'ar': 'إدارة المستخدمين والبلاغات والقاعات والطباعة والإحصائيات.',
    },
    'openAdminPanel': {
      'en': 'Open admin panel',
      'fr': 'Ouvrir le panneau admin',
      'ar': 'فتح لوحة الإدارة',
    },
    'adminPanel': {
      'en': 'Admin',
      'fr': 'Admin',
      'ar': 'الإدارة',
    },
    'adminWelcome': {
      'en': 'Hub control center',
      'fr': 'Centre de contrôle du hub',
      'ar': 'مركز تحكم الهب',
    },
    'adminHeroTitle': {
      'en': 'Run the institution from one place',
      'fr': 'Pilotez l’institution depuis un seul endroit',
      'ar': 'أدِر المؤسسة من مكان واحد',
    },
    'adminHeroSubtitle': {
      'en': 'See teachers, bookings, reports and how users contact the hub.',
      'fr': 'Voyez professeurs, réservations, signalements et contacts hub.',
      'ar': 'شوف عدد الأساتذة والحجوزات والبلاغات وكيف يتواصلوا معاك.',
    },
    'adminAnalytics': {
      'en': 'Analytics',
      'fr': 'Analytics',
      'ar': 'الإحصائيات',
    },
    'adminQuickActions': {
      'en': 'Quick actions',
      'fr': 'Actions rapides',
      'ar': 'إجراءات سريعة',
    },
    'users': {'en': 'Users', 'fr': 'Utilisateurs', 'ar': 'المستخدمون'},
    'hub': {'en': 'Hub', 'fr': 'Hub', 'ar': 'الهب'},
    'reports': {'en': 'Reports', 'fr': 'Signalements', 'ar': 'البلاغات'},
    'teachers': {'en': 'Teachers', 'fr': 'Professeurs', 'ar': 'الأساتذة'},
    'bookings': {'en': 'Bookings', 'fr': 'Réservations', 'ar': 'الحجوزات'},
    'learners': {'en': 'Learners', 'fr': 'Apprenants', 'ar': 'الطلبة'},
    'clients': {'en': 'Clients', 'fr': 'Clients', 'ar': 'العملاء'},
    'messages': {'en': 'Messages', 'fr': 'Messages', 'ar': 'الرسائل'},
    'rooms': {'en': 'Room bookings', 'fr': 'Résa. salles', 'ar': 'حجز القاعات'},
    'printOrders': {'en': 'Print orders', 'fr': 'Commandes print', 'ar': 'طلبات الطباعة'},
    'escrowDeals': {'en': 'Active escrow', 'fr': 'Séquestres actifs', 'ar': 'ضمان نشط'},
    'escrowCompletedDeals': {'en': 'Escrow done', 'fr': 'Séquestres terminés', 'ar': 'ضمان مكتمل'},
    'platformRevenue': {'en': 'Platform fees', 'fr': 'Frais plateforme', 'ar': 'رسوم المنصة'},
    'escrowTracking': {'en': 'Escrow & platform revenue', 'fr': 'Séquestre et revenus plateforme', 'ar': 'الضمان وإيرادات المنصة'},
    'escrowTrackingSummary': {
      'en': '{count} escrow payment(s) logged · {fees} total platform fees collected',
      'fr': '{count} paiement(s) séquestre · {fees} de frais plateforme collectés',
      'ar': '{count} دفعة ضمان · {fees} إجمالي رسوم المنصة',
    },
    'paymentPurposeEscrow': {'en': 'Escrow fund', 'fr': 'Séquestre', 'ar': 'تمويل الضمان'},
    'paymentPurposeEscrowRelease': {'en': 'Platform fee', 'fr': 'Frais plateforme', 'ar': 'رسوم المنصة'},
    'manageUsers': {
      'en': 'Users management',
      'fr': 'Gestion utilisateurs',
      'ar': 'إدارة المستخدمين',
    },
    'manageUsersSub': {
      'en': 'Roles, teachers count, accounts',
      'fr': 'Rôles, nb professeurs, comptes',
      'ar': 'الأدوار وعدد الأساتذة والحسابات',
    },
    'manageReports': {
      'en': 'Reports',
      'fr': 'Signalements',
      'ar': 'البلاغات',
    },
    'manageReportsSub': {
      'en': 'Review flags on users',
      'fr': 'Traiter les signalements',
      'ar': 'مراجعة البلاغات على المستخدمين',
    },
    'manageMarketplace': {
      'en': 'Marketplace',
      'fr': 'Marketplace',
      'ar': 'السوق',
    },
    'manageMarketplaceSub': {
      'en': 'Courses, services & service bookings',
      'fr': 'Cours, services et réservations',
      'ar': 'الدورات والخدمات والحجوزات',
    },
    'manageRooms': {
      'en': 'Rooms rental',
      'fr': 'Location de salles',
      'ar': 'تأجير القاعات',
    },
    'manageRoomsSub': {
      'en': 'Availability, prices /h /day',
      'fr': 'Dispo., tarifs /h /jour',
      'ar': 'التوفر والأسعار بالساعة/اليوم',
    },
    'managePrint': {
      'en': 'Printing services',
      'fr': 'Services impression',
      'ar': 'خدمات الطباعة',
    },
    'managePrintSub': {
      'en': 'Logos, flyers, banners orders',
      'fr': 'Logos, flyers, commandes',
      'ar': 'شعارات وملفات وطلبات الطباعة',
    },
    'manageLogs': {
      'en': 'Logs & payments',
      'fr': 'Journaux & paiements',
      'ar': 'السجلات والمدفوعات',
    },
    'manageLogsSub': {
      'en': 'Payment history and admin actions',
      'fr': 'Historique paiements et actions admin',
      'ar': 'سجل المدفوعات وإجراءات الإدارة',
    },
    'paymentLogs': {
      'en': 'Payment logs',
      'fr': 'Journal paiements',
      'ar': 'سجل المدفوعات',
    },
    'activityLogs': {
      'en': 'Activity logs',
      'fr': 'Journal activité',
      'ar': 'سجل النشاط',
    },
    'noPaymentLogs': {
      'en': 'No payments recorded yet',
      'fr': 'Aucun paiement enregistré',
      'ar': 'لا مدفوعات مسجّلة بعد',
    },
    'noActivityLogs': {
      'en': 'No admin actions yet',
      'fr': 'Aucune action admin',
      'ar': 'لا إجراءات إدارية بعد',
    },
    'markDone': {'en': 'Done', 'fr': 'Terminé', 'ar': 'تم'},
    'anonymousUser': {'en': 'Anonymous', 'fr': 'Anonyme', 'ar': 'مجهول'},
    'system': {'en': 'System', 'fr': 'Système', 'ar': 'النظام'},
    'manageMessages': {
      'en': 'Contact inbox',
      'fr': 'Boîte de contact',
      'ar': 'صندوق التواصل',
    },
    'manageMessagesSub': {
      'en': 'How users contact the hub',
      'fr': 'Comment on vous contacte',
      'ar': 'كيف يتواصلوا معاك',
    },
    'howUsersContact': {
      'en': 'How users can contact you',
      'fr': 'Comment les utilisateurs vous contactent',
      'ar': 'كيفاش يتواصلوا معاك',
    },
    'contactInfo': {
      'en': 'Contact info',
      'fr': 'Infos de contact',
      'ar': 'معلومات التواصل',
    },
    'settings': {
      'en': 'Settings',
      'fr': 'Paramètres',
      'ar': 'الإعدادات',
    },
    'noReports': {
      'en': 'No reports yet',
      'fr': 'Aucun signalement',
      'ar': 'لا توجد بلاغات',
    },
    'reported': {'en': 'Reported', 'fr': 'Signalé', 'ar': 'المُبلَّغ عنه'},
    'reporter': {'en': 'Reporter', 'fr': 'Signalé par', 'ar': 'المُبلِّغ'},
    'resolve': {'en': 'Resolve', 'fr': 'Résoudre', 'ar': 'حل'},
    'dismiss': {'en': 'Dismiss', 'fr': 'Rejeter', 'ar': 'رفض'},
    'noBookings': {
      'en': 'No bookings yet',
      'fr': 'Aucune réservation',
      'ar': 'لا توجد حجوزات',
    },
    'capacity': {'en': 'Capacity', 'fr': 'Capacité', 'ar': 'السعة'},
    'roomBookings': {
      'en': 'Room bookings',
      'fr': 'Réservations salles',
      'ar': 'حجوزات القاعات',
    },
    'printCatalog': {
      'en': 'Print catalog',
      'fr': 'Catalogue impression',
      'ar': 'كتالوج الطباعة',
    },
    'noOrders': {
      'en': 'No print orders',
      'fr': 'Aucune commande',
      'ar': 'لا توجد طلبات',
    },
    'noMessages': {
      'en': 'No messages',
      'fr': 'Aucun message',
      'ar': 'لا توجد رسائل',
    },
    'myMessages': {
      'en': 'My messages',
      'fr': 'Mes messages',
      'ar': 'رسائلي',
    },
    'myMessagesSub': {
      'en': 'Conversations with Samooth Hub',
      'fr': 'Conversations avec Samooth Hub',
      'ar': 'محادثات مع Samooth Hub',
    },
    'composeMessage': {
      'en': 'New message',
      'fr': 'Nouveau message',
      'ar': 'رسالة جديدة',
    },
    'backToMenu': {
      'en': 'Back to menu',
      'fr': 'Retour au menu',
      'ar': 'العودة للقائمة',
    },
    'switchRole': {
      'en': 'Switch role',
      'fr': 'Changer de rôle',
      'ar': 'تغيير الدور',
    },
    'portfolio': {
      'en': 'Portfolio',
      'fr': 'Portfolio',
      'ar': 'معرض الأعمال',
    },
    'previousWork': {
      'en': 'Previous work',
      'fr': 'Travaux précédents',
      'ar': 'أعمال سابقة',
    },
    'publications': {
      'en': 'Publications',
      'fr': 'Publications',
      'ar': 'المنشورات',
    },
    'noPublications': {
      'en': 'No publications yet',
      'fr': 'Aucune publication pour le moment',
      'ar': 'لا منشورات بعد',
    },
    'newPublication': {
      'en': 'New publication',
      'fr': 'Nouvelle publication',
      'ar': 'منشور جديد',
    },
    'hashtags': {
      'en': 'Hashtags',
      'fr': 'Hashtags',
      'ar': 'الوسوم',
    },
    'hashtagsHint': {
      'en': 'Add hashtags to classify your post (e.g. #design #project)',
      'fr': 'Ajoutez des hashtags pour classer votre publication (ex. #design #projet)',
      'ar': 'أضف وسوماً لتصنيف منشورك (مثلاً #design #project)',
    },
    'publish': {
      'en': 'Publish',
      'fr': 'Publier',
      'ar': 'نشر',
    },
    'hubFacilities': {
      'en': 'Hub facilities',
      'fr': 'Services du hub',
      'ar': 'خدمات الهب',
    },
    'hubFacilitiesSub': {
      'en': 'Rent rooms, printing (logos/files), contact the institution.',
      'fr': 'Louer des salles, impression (logos/fichiers), contacter le hub.',
      'ar': 'تأجير القاعات، طباعة الشعارات والملفات، والتواصل مع المؤسسة.',
    },
    'rentRooms': {
      'en': 'Rent a room',
      'fr': 'Louer une salle',
      'ar': 'استأجر قاعة',
    },
    'rentRoomsSub': {
      'en': 'Available rooms with hourly or daily rates for teachers & trainers.',
      'fr': 'Salles dispo. — tarifs à l’heure ou à la journée pour formateurs.',
      'ar': 'قاعات متاحة بأسعار بالساعة أو باليوم للأساتذة والمكوّنين.',
    },
    'printingServices': {
      'en': 'Printing services',
      'fr': 'Services d’impression',
      'ar': 'خدمات الطباعة',
    },
    'printingServicesSub': {
      'en': 'Print logos, flyers, banners and brand files at the hub.',
      'fr': 'Imprimez logos, flyers, bannières et fichiers au hub.',
      'ar': 'اطبع الشعارات والملفات والبنرات في الهب.',
    },
    'contactHub': {
      'en': 'Contact the hub',
      'fr': 'Contacter le hub',
      'ar': 'تواصل مع الهب',
    },
    'contactHubSub': {
      'en': 'Send a message — phone, email or in-app.',
      'fr': 'Envoyez un message — téléphone, email ou in-app.',
      'ar': 'أرسل رسالة — هاتف، إيميل أو من التطبيق.',
    },
    'available': {'en': 'Available', 'fr': 'Disponible', 'ar': 'متاحة'},
    'unavailable': {'en': 'Unavailable', 'fr': 'Indisponible', 'ar': 'غير متاحة'},
    'bookHours': {'en': 'Book /h', 'fr': 'Réserver /h', 'ar': 'احجز /س'},
    'bookDay': {'en': 'Book /day', 'fr': 'Réserver /j', 'ar': 'احجز /يوم'},
    'roomBooked': {
      'en': 'Room booking confirmed',
      'fr': 'Réservation salle confirmée',
      'ar': 'تم تأكيد حجز القاعة',
    },
    'printOrdered': {
      'en': 'Print order placed',
      'fr': 'Commande impression envoyée',
      'ar': 'تم إرسال طلب الطباعة',
    },
    'subject': {'en': 'Subject', 'fr': 'Sujet', 'ar': 'الموضوع'},
    'message': {'en': 'Message', 'fr': 'Message', 'ar': 'الرسالة'},
    'sendMessage': {
      'en': 'Send message',
      'fr': 'Envoyer',
      'ar': 'إرسال',
    },
    'messageSent': {
      'en': 'Message sent to the hub',
      'fr': 'Message envoyé au hub',
      'ar': 'تم إرسال الرسالة إلى الهب',
    },
    'directMessages': {
      'en': 'Direct messages',
      'fr': 'Messages directs',
      'ar': 'رسائل مباشرة',
    },
    'directMessage': {
      'en': 'Direct message',
      'fr': 'Message direct',
      'ar': 'رسالة مباشرة',
    },
    'hubSupport': {
      'en': 'Hub support',
      'fr': 'Support hub',
      'ar': 'دعم الهب',
    },
    'startConversation': {
      'en': 'Say hello to start the conversation.',
      'fr': 'Dites bonjour pour commencer.',
      'ar': 'قل مرحباً لبدء المحادثة.',
    },
    'sendOffer': {
      'en': 'Send offer',
      'fr': 'Envoyer une offre',
      'ar': 'إرسال عرض',
    },
    'offerTitle': {
      'en': 'Offer title',
      'fr': 'Titre de l’offre',
      'ar': 'عنوان العرض',
    },
    'offerDescription': {
      'en': 'Scope & deliverables',
      'fr': 'Périmètre et livrables',
      'ar': 'نطاق العمل والتسليم',
    },
    'offerAmount': {
      'en': 'Price (DZD)',
      'fr': 'Prix (DZD)',
      'ar': 'السعر (د.ج)',
    },
    'payEscrow': {
      'en': 'Pay into escrow',
      'fr': 'Payer en séquestre',
      'ar': 'الدفع في الضمان',
    },
    'markDelivered': {
      'en': 'Mark as delivered',
      'fr': 'Marquer livré',
      'ar': 'تحديد كمُسلّم',
    },
    'approveRelease': {
      'en': 'Approve & release',
      'fr': 'Approuver et libérer',
      'ar': 'الموافقة والتحرير',
    },
    'approveReleaseConfirm': {
      'en': 'Release {amount} from escrow to the freelancer? 10% platform fee applies.',
      'fr': 'Libérer {amount} du séquestre au freelance ? Frais plateforme 10 %.',
      'ar': 'تحرير {amount} من الضمان للمستقل؟ رسوم المنصة 10٪.',
    },
    'escrowReleased': {
      'en': 'Payment released to freelancer',
      'fr': 'Paiement libéré au freelance',
      'ar': 'تم تحرير الدفع للمستقل',
    },
    'escrowOffer': {
      'en': 'Escrow offer',
      'fr': 'Offre séquestre',
      'ar': 'عرض ضمان',
    },
    'escrowPending': {
      'en': 'Awaiting payment',
      'fr': 'En attente de paiement',
      'ar': 'في انتظار الدفع',
    },
    'escrowFunded': {
      'en': 'Funded',
      'fr': 'Financé',
      'ar': 'ممول',
    },
    'escrowDelivered': {
      'en': 'Delivered',
      'fr': 'Livré',
      'ar': 'مُسلّم',
    },
    'escrowCompleted': {
      'en': 'Completed',
      'fr': 'Terminé',
      'ar': 'مكتمل',
    },
    'escrowCancelled': {
      'en': 'Cancelled',
      'fr': 'Annulé',
      'ar': 'ملغى',
    },
    'escrowPaySubtitle': {
      'en': 'Funds held until you approve delivery',
      'fr': 'Fonds bloqués jusqu’à votre approbation',
      'ar': 'الأموال محجوزة حتى موافقتك على التسليم',
    },
    'escrowFeeNote': {
      'en': '10% platform fee ({fee}) on release',
      'fr': 'Frais plateforme 10 % ({fee}) à la libération',
      'ar': 'رسوم المنصة 10٪ ({fee}) عند التحرير',
    },
    'escrowPayoutSummary': {
      'en': 'Released: {payout} to freelancer · {fee} platform fee',
      'fr': 'Libéré : {payout} au freelance · {fee} frais plateforme',
      'ar': 'تم التحرير: {payout} للمستقل · {fee} رسوم المنصة',
    },
    'backToConversation': {
      'en': 'Back to conversation',
      'fr': 'Retour à la conversation',
      'ar': 'العودة إلى المحادثة',
    },
    'replyViaEmail': {
      'en': 'Reply from hub email',
      'fr': 'Répondre depuis l’email du hub',
      'ar': 'الرد من بريد الهب',
    },
    'contactHubWelcome': {
      'en': 'Hello! Send us a message about rooms, printing, or anything you need from the hub.',
      'fr': 'Bonjour ! Écrivez-nous pour les salles, l’impression ou toute question sur le hub.',
      'ar': 'مرحباً! أرسل لنا رسالة حول القاعات أو الطباعة أو أي استفسار عن الهب.',
    },
    'typeYourMessage': {
      'en': 'Type your message…',
      'fr': 'Écrivez votre message…',
      'ar': 'اكتب رسالتك…',
    },
    'today': {
      'en': 'Today',
      'fr': 'Aujourd’hui',
      'ar': 'اليوم',
    },
    'reportUser': {
      'en': 'Report a user',
      'fr': 'Signaler quelqu’un',
      'ar': 'بلّغ على شخص',
    },
    'reportUserSub': {
      'en': 'File a report for moderation',
      'fr': 'Déposer un signalement',
      'ar': 'قدّم بلاغ للمراجعة',
    },
    'reason': {'en': 'Reason', 'fr': 'Motif', 'ar': 'السبب'},
    'details': {'en': 'Details', 'fr': 'Détails', 'ar': 'التفاصيل'},
    'submitReport': {
      'en': 'Submit report',
      'fr': 'Envoyer le signalement',
      'ar': 'إرسال البلاغ',
    },
    'reportSent': {
      'en': 'Report submitted — admin will review',
      'fr': 'Signalement envoyé — l’admin va traiter',
      'ar': 'تم إرسال البلاغ — الإدارة تراجعه',
    },
    'allUsers': {'en': 'All', 'fr': 'Tous', 'ar': 'الكل'},
    'noUsersInCategory': {
      'en': 'No users in this category',
      'fr': 'Aucun utilisateur dans cette catégorie',
      'ar': 'لا مستخدمين في هذه الفئة',
    },
    'editUser': {'en': 'Edit user', 'fr': 'Modifier', 'ar': 'تعديل'},
    'displayName': {'en': 'Display name', 'fr': 'Nom affiché', 'ar': 'الاسم المعروض'},
    'bio': {'en': 'Bio', 'fr': 'Bio', 'ar': 'نبذة'},
    'cancel': {'en': 'Cancel', 'fr': 'Annuler', 'ar': 'إلغاء'},
    'save': {'en': 'Save', 'fr': 'Enregistrer', 'ar': 'حفظ'},
    'delete': {'en': 'Delete', 'fr': 'Supprimer', 'ar': 'حذف'},
    'deleteUser': {'en': 'Delete user', 'fr': 'Supprimer utilisateur', 'ar': 'حذف المستخدم'},
    'deleteUserConfirm': {
      'en': 'Delete this account permanently? This cannot be undone.',
      'fr': 'Supprimer ce compte définitivement ? Action irréversible.',
      'ar': 'حذف هذا الحساب نهائياً؟ لا يمكن التراجع.',
    },
    'userUpdated': {
      'en': 'User profile updated',
      'fr': 'Profil mis à jour',
      'ar': 'تم تحديث الملف',
    },
    'userDeleted': {
      'en': 'User deleted',
      'fr': 'Utilisateur supprimé',
      'ar': 'تم حذف المستخدم',
    },
    'blockUser': {'en': 'Block', 'fr': 'Bloquer', 'ar': 'حظر'},
    'unlockUser': {'en': 'Unlock', 'fr': 'Débloquer', 'ar': 'إلغاء الحظر'},
    'userBlocked': {
      'en': 'User blocked',
      'fr': 'Utilisateur bloqué',
      'ar': 'تم حظر المستخدم',
    },
    'userUnlocked': {
      'en': 'User unlocked',
      'fr': 'Utilisateur débloqué',
      'ar': 'تم إلغاء حظر المستخدم',
    },
    'adminHubRedirect': {
      'en': 'Room rental and printing are for teachers and clients. As admin, manage facilities from the dashboard (rooms, print orders).',
      'fr': 'Location de salles et impression sont pour enseignants/clients. En tant qu’admin, gérez depuis le tableau de bord.',
      'ar': 'تأجير القاعات والطباعة للأساتذة والعملاء. كمدير، أدِرها من لوحة التحكم.',
    },
    'searchUserToReport': {
      'en': 'Search by name or email…',
      'fr': 'Rechercher par nom ou email…',
      'ar': 'ابحث بالاسم أو الإيميل…',
    },
    'searchUserHint': {
      'en': 'Type at least 2 characters to find someone to report',
      'fr': 'Tapez au moins 2 caractères pour trouver quelqu’un',
      'ar': 'اكتب حرفين على الأقل للبحث',
    },
    'noUsersFound': {
      'en': 'No users found',
      'fr': 'Aucun utilisateur trouvé',
      'ar': 'لم يُعثر على مستخدمين',
    },
    'userNotFound': {
      'en': 'User not found',
      'fr': 'Utilisateur introuvable',
      'ar': 'المستخدم غير موجود',
    },
    'announcements': {
      'en': 'Announcements',
      'fr': 'Annonces',
      'ar': 'الإعلانات',
    },

    'notifications': {'en': 'Notifications', 'fr': 'Notifications', 'ar': 'الإشعارات'},
    'privacySecurity': {'en': 'Privacy & Security', 'fr': 'Confidentialité & Sécurité', 'ar': 'الخصوصية والأمان'},
    'appearance': {'en': 'Appearance', 'fr': 'Apparence', 'ar': 'المظهر'},
    'helpSupport': {'en': 'Help & Support', 'fr': 'Aide & Support', 'ar': 'المساعدة والدعم'},
    'aboutApp': {'en': 'About Samooth', 'fr': 'À propos de Samooth', 'ar': 'حول Samooth'},
    'shareApp': {'en': 'Share app', 'fr': 'Partager l’app', 'ar': 'مشاركة التطبيق'},
    'shareWithOthers': {'en': 'Share with others', 'fr': 'Partager avec d’autres', 'ar': 'شارك مع الآخرين'},
    'copyLink': {'en': 'Copy link', 'fr': 'Copier le lien', 'ar': 'نسخ الرابط'},
    'linkCopied': {'en': 'Link copied to clipboard', 'fr': 'Lien copié', 'ar': 'تم نسخ الرابط'},
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
