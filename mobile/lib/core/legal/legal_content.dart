import 'package:flutter/material.dart';

class LegalBulletSection {
  const LegalBulletSection({
    required this.title,
    required this.bullets,
  });

  final String title;
  final List<String> bullets;
}

/// Trilingual About Us & Terms / Privacy copy for settings screens.
abstract final class LegalContent {
  static String aboutUsTitle(Locale locale) => _pick(locale, en: 'About Us — Samooth', fr: 'Qui sommes-nous — Samooth', ar: 'من نحن — Samooth');

  static String aboutUsBody(Locale locale) => _pick(
        locale,
        en:
            'At Samooth, we build the foremost digital and physical bridge for the knowledge economy. We combine high-performance professional training in our equipped spaces (Samooth Hub) with a smart platform that connects young talent to project owners and startups. Our vision is to empower the next generation with digital skills and facilitate professional integration at the highest standards of quality and professionalism.',
        fr:
            'Chez Samooth, nous construisons le pont numérique et physique le plus visible pour l’économie de la connaissance. Nous allions une formation professionnelle haute performance dans nos espaces équipés (Samooth Hub) à une plateforme intelligente qui relie les jeunes talents aux porteurs de projets et aux startups. Notre vision : doter la prochaine génération de compétences numériques et faciliter l’insertion professionnelle aux plus hauts standards de qualité et de professionnalisme.',
        ar:
            'نحن في Samooth نصنع الجسر الرقمي والمادي الأبرز لاقتصاد المعرفة. ندمج بين التكوين الاحترافي عالي الأداء في مساحاتنا المجهزة (Samooth Hub) ومنصة ذكية تربط الكفاءات الشابة بأصحاب المشاريع والشركات الناشئة. رؤيتنا هي تمكين الجيل القادم من المهارات الرقمية وتسهيل الاندماج المهني بأعلى معايير الجودة والاحترافية.',
      );

  static String termsPrivacyTitle(Locale locale) => _pick(
        locale,
        en: 'Terms & Privacy Policy',
        fr: 'Conditions et politique de confidentialité',
        ar: 'الشروط وسياسة الخصوصية',
      );

  static List<LegalBulletSection> termsSections(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return _termsFr;
      case 'ar':
        return _termsAr;
      default:
        return _termsEn;
    }
  }

  static String _pick(Locale locale, {required String en, required String fr, required String ar}) {
    return switch (locale.languageCode) {
      'fr' => fr,
      'ar' => ar,
      _ => en,
    };
  }

  static const _termsAr = [
    LegalBulletSection(
      title: 'الشروط الخاصة بالطلاب (Étudiants / Learners)',
      bullets: [
        'الالتزام بالتكوين: الحضور الفعّال والاستفادة القصوى من الورشات والمعدات المقدمة داخل Samooth Hub.',
        'الاستخدام العادل: الالتزام بقواعد الاستخدام الرقمي للمنصة وعدم مشاركة الحسابات الشخصية.',
        'الخصوصية: تحمي منصة Samooth بياناتك الشخصية ومسارك التعليمي، ولا يتم مشاركتها مع الشركات إلا بموافقتك المباشرة بغرض التوظيف.',
      ],
    ),
    LegalBulletSection(
      title: 'الشروط الخاصة بمعلمي وخبراء المنصة (Formateurs & Experts)',
      bullets: [
        'جودة المحتوى: تقديم محتوى تدريبي أصلي، حديث، وعالي الجودة يتناسب مع متطلبات سوق العمل الرقمي.',
        'الملكية الفكرية: يحافظ الخبير على حقوق ملكيته الفكرية للمحتوى المقدم، مع منح المنصة حق عرضه للمستفيدين.',
        'الخصوصية: التزام تام بسرية بيانات المتدربين وعدم استغلالها خارج نطاق المنصة التدريبي.',
      ],
    ),
    LegalBulletSection(
      title: 'الشروط الخاصة بالـ Freelancers وأصحاب المشاريع',
      bullets: [
        'الاحترافية والموثوقية: الالتزام بالمواعيد النهائية لتسليم المشاريع المتفق عليها عبر نظام المطابقة الذكية.',
        'المعاملات المالية الآمنة: جميع المعاملات المالية واستخدام نظام "الـ Tokens" تخضع لرقابة وحماية أمان المنصة.',
        'الخصوصية وسرية العمل: حماية البيانات والمعلومات الخاصة بالمشاريع والشركات الناشئة المتعاقد معها وعدم تسريبها.',
      ],
    ),
    LegalBulletSection(
      title: 'استخدام التطبيق (App Usage)',
      bullets: [
        'الالتزام باستخدام التطبيق بالطريقة الصحيحة والمسؤولة لضمان تجربة تعلم سلسة وآمنة لجميع المستخدمين.',
      ],
    ),
    LegalBulletSection(
      title: 'احترام الدروس والمحتوى (Courses & Content Respect)',
      bullets: [
        'حضور الدروس والمحتوى التكويني بانتظام، وعدم إعادة نشر أو قرصنة المواد التعليمية الخاصة بالمنصة.',
      ],
    ),
    LegalBulletSection(
      title: 'الدفع والاشتراكات (Payments & Subscriptions)',
      bullets: [
        'الالتزام بتسديد رسوم الاشتراكات أو حزم الـ (Tokens) في مواقيتها المحددة لضمان استمرار الوصول للخدمات.',
      ],
    ),
    LegalBulletSection(
      title: 'الاحترام المتبادل والبيئة الآمنة (Mutual Respect)',
      bullets: [
        'الحفاظ على بيئة محترمة وآمنة داخل مجتمع المنصة، والتعامل الراقي مع المدربين والزملاء.',
      ],
    ),
    LegalBulletSection(
      title: 'الخصوصية وحماية البيانات (Privacy & Data)',
      bullets: [
        'التزام المنصة بحماية بياناتك الشخصية ومسارك التعليمي وعدم مشاركتها إلا بإذنك.',
      ],
    ),
  ];

  static const _termsFr = [
    LegalBulletSection(
      title: 'Conditions — Étudiants / Learners',
      bullets: [
        'Engagement formation : assiduité et usage optimal des ateliers et équipements du Samooth Hub.',
        'Usage loyal : respect des règles numériques de la plateforme et non-partage des comptes personnels.',
        'Confidentialité : Samooth protège vos données et votre parcours ; aucun partage avec des entreprises sans votre accord explicite (insertion professionnelle).',
      ],
    ),
    LegalBulletSection(
      title: 'Conditions — Formateurs & Experts',
      bullets: [
        'Qualité du contenu : contenu original, actuel et aligné sur le marché du travail numérique.',
        'Propriété intellectuelle : l’expert conserve ses droits ; la plateforme obtient le droit de diffusion aux apprenants.',
        'Confidentialité : secret strict sur les données des apprenants, sans usage hors cadre pédagogique.',
      ],
    ),
    LegalBulletSection(
      title: 'Conditions — Freelancers & Porteurs de projets',
      bullets: [
        'Professionnalisme : respect des délais convenus via le système de matching intelligent.',
        'Paiements sécurisés : transactions et Tokens supervisés par les mécanismes de sécurité de la plateforme.',
        'Confidentialité : protection des données et informations des projets et startups partenaires.',
      ],
    ),
    LegalBulletSection(
      title: 'Utilisation de l’application',
      bullets: [
        'Utiliser l’application de manière responsable pour une expérience d’apprentissage fluide et sûre pour tous.',
      ],
    ),
    LegalBulletSection(
      title: 'Respect des cours et contenus',
      bullets: [
        'Assister régulièrement aux cours et ne pas republier ni pirater les supports pédagogiques de la plateforme.',
      ],
    ),
    LegalBulletSection(
      title: 'Paiements et abonnements',
      bullets: [
        'Régler les abonnements ou packs de Tokens aux échéances prévues pour maintenir l’accès aux services.',
      ],
    ),
    LegalBulletSection(
      title: 'Respect mutuel et environnement sûr',
      bullets: [
        'Maintenir une communauté respectueuse et sécurisée ; interactions courtoises avec formateurs et pairs.',
      ],
    ),
    LegalBulletSection(
      title: 'Confidentialité et protection des données',
      bullets: [
        'La plateforme s’engage à protéger vos données personnelles et votre parcours ; aucun partage sans votre consentement.',
      ],
    ),
  ];

  static const _termsEn = [
    LegalBulletSection(
      title: 'Terms — Learners / Students',
      bullets: [
        'Training commitment: active attendance and full use of workshops and equipment at Samooth Hub.',
        'Fair use: follow platform digital rules and do not share personal accounts.',
        'Privacy: Samooth protects your personal data and learning path; shared with companies only with your explicit consent for employment purposes.',
      ],
    ),
    LegalBulletSection(
      title: 'Terms — Teachers & Experts',
      bullets: [
        'Content quality: provide original, up-to-date training aligned with the digital job market.',
        'Intellectual property: experts keep ownership; the platform receives display rights for learners.',
        'Privacy: strict confidentiality of learner data; no use outside the training platform.',
      ],
    ),
    LegalBulletSection(
      title: 'Terms — Freelancers & Project Owners',
      bullets: [
        'Professionalism: meet agreed deadlines via the smart matching system.',
        'Secure payments: all transactions and Tokens are protected by platform security.',
        'Confidentiality: protect project and startup data; no unauthorized disclosure.',
      ],
    ),
    LegalBulletSection(
      title: 'App usage',
      bullets: [
        'Use the app responsibly to ensure a smooth, safe learning experience for everyone.',
      ],
    ),
    LegalBulletSection(
      title: 'Courses & content respect',
      bullets: [
        'Attend courses regularly; do not republish or pirate platform learning materials.',
      ],
    ),
    LegalBulletSection(
      title: 'Payments & subscriptions',
      bullets: [
        'Pay subscription fees or Token packs on time to keep access to services.',
      ],
    ),
    LegalBulletSection(
      title: 'Mutual respect & safe environment',
      bullets: [
        'Maintain a respectful, safe community; interact courteously with trainers and peers.',
      ],
    ),
    LegalBulletSection(
      title: 'Privacy & data protection',
      bullets: [
        'The platform protects your personal data and learning path; nothing is shared without your permission.',
      ],
    ),
  ];
}
