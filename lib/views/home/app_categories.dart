import 'package:flutter/material.dart';

/// كلاس التصنيفات الشامل لتطبيق "الموسوعة الشاملة"
/// تم تصميمه ليكون متوافقاً مع محركات البحث (Search Engines) عبر الكلمات المفتاحية
class AppCategories {
  static List<Map<String, dynamic>> allCategories = [
    // ================= 1. الأدب والروايات =================
    {
      "id": "literature",
      "name": "الأدب والروايات",
      "icon": Icons.menu_book_rounded,
      "color": const Color(0xFF6A1B9A), // Purple
      "subCategories": [
        {
          "name": "دراما",
          "query": "subject:(drama) OR (دراما)",
          "keywords": ["مسرح", "رواية اجتماعية", "قصص واقعية", "نقد أدبي"]
        },
        {
          "name": "رعب وغموض",
          "query": "subject:(horror OR mystery) OR (رعب)",
          "keywords": ["تشويق", "جريمة", "بوليسي", "ما وراء الطبيعة", "أشباح"]
        },
        {
          "name": "خيال علمي وفانتازيا",
          "query": "subject:(science fiction OR fantasy) OR (خيال علمي)",
          "keywords": ["فضاء", "عوالم موازية", "تنانين", "سحر", "ديستوبيا"]
        },
        {
          "name": "شعر وأدب",
          "query": "subject:(poetry OR literature) OR (شعر عربي)",
          "keywords": ["قصائد", "نثر", "أدب جاهلي", "المعلقات", "بلاغة"]
        },
      ]
    },

    // ================= 2. التقنية والبرمجة (تخصصك يا بشمهندس) =================
    {
      "id": "technology",
      "name": "التقنية والبرمجة",
      "icon": Icons.terminal_rounded,
      "color": const Color(0xFF263238), // Blue Grey Dark
      "subCategories": [
        {
          "name": "تطوير الموبايل",
          "query": "(flutter) OR (android) OR (ios) OR (mobile development)",
          "keywords": ["برمجة تطبيقات", "فلاتر", "دارت", "اندرويد", "سويفت", "BLoC"]
        },
        {
          "name": "تطوير الويب",
          "query": "subject:(web development) OR (javascript OR html OR css)",
          "keywords": ["فرونت إند", "باك إند", "تصميم مواقع", "React", "Nodejs"]
        },
        {
          "name": "الذكاء الاصطناعي",
          "query": "subject:(artificial intelligence OR machine learning) OR (ذكاء اصطناعي)",
          "keywords": ["بيانات ضخمة", "تعلم الآلة", "روبوتات", "بايثون", "خوارزميات"]
        },
        {
          "name": "الأمن السيبراني",
          "query": "subject:(cybersecurity OR hacking) OR (أمن المعلومات)",
          "keywords": ["تشفير", "اختراق أخلاقي", "لينكس", "شبكات", "حماية"]
        },
      ]
    },

    // ================= 3. تطوير الذات والمال =================
    {
      "id": "self_improvement",
      "name": "تطوير الذات والمال",
      "icon": Icons.trending_up_rounded,
      "color": const Color(0xFF2E7D32), // Green
      "subCategories": [
        {
          "name": "تنمية بشرية",
          "query": "subject:(self-help OR motivation) OR (تنمية بشرية)",
          "keywords": ["ثقة بالنفس", "إدارة الوقت", "نجاح", "عادات", "تحفيز"]
        },
        {
          "name": "مال وأعمال",
          "query": "subject:(finance OR business OR investment) OR (مال وأعمال)",
          "keywords": ["بورصة", "ريادة أعمال", "تسويق", "استثمار", "ثراء"]
        },
        {
          "name": "علم نفس",
          "query": "subject:(psychology) OR (علم نفس)",
          "keywords": ["تحليل شخصية", "لغة جسد", "ذكاء عاطفي", "علاج نفسي"]
        },
      ]
    },

    // ================= 4. علوم ومعرفة =================
    {
      "id": "science_history",
      "name": "علوم ومعرفة",
      "icon": Icons.biotech_rounded,
      "color": const Color(0xFF00838F), // Cyan
      "subCategories": [
        {
          "name": "تاريخ وحضارات",
          "query": "subject:(history OR civilization) OR (تاريخ)",
          "keywords": ["قديم", "إسلامي", "حضارة مصرية", "حروب عالمية", "سير أعلام"]
        },
        {
          "name": "فيزياء وفلك",
          "query": "subject:(physics OR astronomy) OR (فيزياء)",
          "keywords": ["كون", "كم", "نجوم", "كواكب", "طاقة", "نسبية"]
        },
        {
          "name": "فلسفة وفكر",
          "query": "subject:(philosophy) OR (فلسفة)",
          "keywords": ["منطق", "فكر إسلامي", "تأمل", "وجودية", "وعي"]
        },
      ]
    },

    // ================= 5. دين وتراث =================
    {
      "id": "religion",
      "name": "دين وتراث",
      "icon": Icons.mosque_rounded,
      "color": const Color(0xFF1B5E20), // Dark Green
      "subCategories": [
        {
          "name": "علوم القرآن",
          "query": "subject:(quran OR tafsir) OR (تفسير القرآن)",
          "keywords": ["تجويد", "إعجاز", "قرآن كريم", "أسباب النزول"]
        },
        {
          "name": "السيرة والحديث",
          "query": "subject:(hadith OR prophet) OR (السيرة النبوية)",
          "keywords": ["سنة", "صحابة", "بخاري ومسلم", "قصص الأنبياء"]
        },
        {
          "name": "فقه وعبادات",
          "query": "subject:(fiqh OR Sharia) OR (فقه)",
          "keywords": ["أحكام", "صلاة", "زكاة", "معاملات إسلامية"]
        },
      ]
    },

    // ================= 6. فنون وتصميم (UI/UX) =================
    {
      "id": "arts",
      "name": "فنون وتصميم",
      "icon": Icons.palette_rounded,
      "color": const Color(0xFFAD1457), // Pink
      "subCategories": [
        {
          "name": "تصميم UI/UX",
          "query": "(ui ux design) OR (واجهة المستخدم) OR (figma)",
          "keywords": ["تجربة مستخدم", "فيجما", "تخطيط", "ألوان", "نماذج"]
        },
        {
          "name": "رسم وفنون تشكيلية",
          "query": "subject:(art OR drawing) OR (رسم)",
          "keywords": ["تصوير", "نحت", "خط عربي", "زخرفة", "فنون رقمية"]
        },
        {
          "name": "عمارة وديكور",
          "query": "subject:(architecture) OR (هندسة معمارية)",
          "keywords": ["تصميم داخلي", "بناء", "خرائط", "مدن"]
        },
      ]
    },

    // ================= 7. صحة وعائلة =================
    {
      "id": "health_family",
      "name": "صحة وعائلة",
      "icon": Icons.health_and_safety_rounded,
      "color": const Color(0xFFC62828), // Red
      "subCategories": [
        {
          "name": "طب وصحة",
          "query": "subject:(medicine OR health) OR (طب)",
          "keywords": ["تغذية", "لياقة", "وقاية", "أعشاب", "تمريض"]
        },
        {
          "name": "تربية وأطفال",
          "query": "subject:(parenting OR children) OR (تربية)",
          "keywords": ["عائلة", "مراهقة", "قصص أطفال", "تعليم مبكر"]
        },
      ]
    },

    // ================= 8. اقتصاد حديث ونادر =================
    {
      "id": "modern_economy",
      "name": "اقتصاد حديث ونادر",
      "icon": Icons.currency_bitcoin_rounded,
      "color": const Color(0xFFE65100), // Orange Dark
      "subCategories": [
        {
          "name": "عملات رقمية",
          "query": "(bitcoin OR blockchain OR crypto)",
          "keywords": ["بيتكوين", "بلوكشين", "تعدين", "محفظة رقمية"]
        },
        {
          "name": "ما وراء الطبيعة",
          "query": "subject:(parapsychology OR metaphysics) OR (ما وراء الطبيعة)",
          "keywords": ["تفسير أحلام", "أساطير", "باراسيكولوجي", "ميتافيزيقيا"]
        },
      ]
    },
    // ================= 15. القانون والسياسة =================
    {
      "id": "law_politics",
      "name": "القانون والسياسة",
      "icon": Icons.gavel_rounded,
      "color": const Color(0xFF455A64), // Blue Grey
      "subCategories": [
        {
          "name": "قانون دولي وحقوق",
          "query": "subject:(international law OR human rights) OR (حقوق الإنسان)",
          "keywords": ["قانون جنائي", "محاماة", "دستور", "حقوق دولية", "اتفاقيات"]
        },
        {
          "name": "علوم سياسية",
          "query": "subject:(political science OR geopolitics) OR (سياسة)",
          "keywords": ["علاقات دولية", "دبلوماسية", "نظم حكم", "أيديولوجيا", "جيوسياسة"]
        },
        {
          "name": "إدارة عامة",
          "query": "subject:(public administration) OR (إدارة عامة)",
          "keywords": ["تخطيط استراتيجي", "حوكمة", "مؤسسات", "سياسات عامة"]
        },
      ]
    },

    // ================= 16. لغات وترجمة =================
    {
      "id": "languages",
      "name": "اللغات والترجمة",
      "icon": Icons.translate_rounded,
      "color": const Color(0xFF1565C0), // Royal Blue
      "subCategories": [
        {
          "name": "اللغة العربية",
          "query": "subject:(Arabic language OR grammar) OR (اللغة العربية)",
          "keywords": ["نحو وصرف", "بلاغة", "إعراب", "فقه اللغة", "أدب عربي"]
        },
        {
          "name": "اللغة الإنجليزية",
          "query": "subject:(English language learning OR linguistics) OR (تعلم الإنجليزية)",
          "keywords": ["IELTS", "TOEFL", "قواعد", "مفردات", "ترجمة إنجليزية"]
        },
        {
          "name": "فن الترجمة",
          "query": "subject:(translation studies) OR (الترجمة)",
          "keywords": ["ترجمة فورية", "تعريب", "ترجمة أدبية", "نظريات الترجمة"]
        },
      ]
    },

    // ================= 17. الزراعة والبيئة =================
    {
      "id": "agriculture_environment",
      "name": "الزراعة والبيئة",
      "icon": Icons.eco_rounded,
      "color": const Color(0xFF388E3C), // Forest Green
      "subCategories": [
        {
          "name": "علوم زراعية",
          "query": "subject:(agriculture OR farming) OR (زراعة)",
          "keywords": ["إنتاج نباتي", "تربة", "ري", "وقاية مزروعات", "زراعة عضوية"]
        },
        {
          "name": "علوم البيئة",
          "query": "subject:(ecology OR environmental science) OR (بيئة)",
          "keywords": ["تغير مناخي", "استدامة", "تلوث", "موارد طبيعية", "طاقة متجددة"]
        },
        {
          "name": "عالم الحيوان",
          "query": "subject:(zoology OR animals) OR (حيوانات)",
          "keywords": ["بيطرة", "طيور", "أسماك", "حياة برية", "تربية خيول"]
        },
      ]
    },

    // ================= 18. مهارات حياتية وهوايات =================
    {
      "id": "lifestyle_hobbies",
      "name": "مهارات وحياة",
      "icon": Icons.extension_rounded,
      "color": const Color(0xFFF57C00), // Orange
      "subCategories": [
        {
          "name": "فنون الطبخ",
          "query": "subject:(cooking OR recipes) OR (طبخ)",
          "keywords": ["حلويات", "مأكولات شرقية", "إتيكيت", "تغذية صحية", "شيف"]
        },
        {
          "name": "تصميم وديكور",
          "query": "subject:(interior design OR decoration) OR (ديكور)",
          "keywords": ["أثاث", "تنسيق ألوان", "عمارة داخلية", "ترميم"]
        },
        {
          "name": "الرياضة والقتال",
          "query": "subject:(sports OR martial arts) OR (رياضة)",
          "keywords": ["لياقة", "كاراتيه", "شطرنج", "تدريب بدني", "يوغا"]
        },
      ]
    },

    // ================= 19. إعلام وصناعة محتوى =================
    {
      "id": "media_content",
      "name": "الإعلام والاتصال",
      "icon": Icons.campaign_rounded,
      "color": const Color(0xFFD32F2F), // Strong Red
      "subCategories": [
        {
          "name": "الصحافة والإعلام",
          "query": "subject:(journalism OR mass media) OR (صحافة)",
          "keywords": ["إذاعة وتلفزيون", "تحقيق صحفي", "إعلام رقمي", "أخلاقيات المهنة"]
        },
        {
          "name": "صناعة المحتوى",
          "query": "(content creation) OR (social media marketing) OR (يوتيوب)",
          "keywords": ["بودكاست", "تأثير", "كتابة إعلانية", "مونتاج", "سرد قصصي"]
        },
        {
          "name": "الخطابة والإلقاء",
          "query": "subject:(public speaking OR rhetoric) OR (خطابة)",
          "keywords": ["إلقاء", "كاريزما", "لغة الجسد", "إقناع", "تواصل"]
        },
      ]
    },

    // ================= 20. موسوعات وملخصات (الخلاصة) =================
    {
      "id": "encyclopedias",
      "name": "الموسوعات والملخصات",
      "icon": Icons.auto_stories_rounded,
      "color": const Color(0xFF5D4037), // Brown
      "subCategories": [
        {
          "name": "موسوعات عامة",
          "query": "subject:(encyclopedia) OR (موسوعة)",
          "keywords": ["حقائق", "أرقام قياسية", "معارف عامة", "غرائب"]
        },
        {
          "name": "ملخصات كتب",
          "query": "subject:(book summaries) OR (ملخصات)",
          "keywords": ["أفكار", "قراءة سريعة", "مراجعات كتب", "أفضل الكتب"]
        },
      ]
    },// ================= 21. الهندسة والتصنيع =================
    {
      "id": "engineering",
      "name": "الهندسة والتكنولوجيا",
      "icon": Icons.architecture_rounded,
      "color": const Color(0xFF37474F), // Slate Grey
      "subCategories": [
        {
          "name": "هندسة مدنية ومعمارية",
          "query": "subject:(civil engineering OR architecture) OR (هندسة مدنية)",
          "keywords": ["خرسانة", "تصميم إنشائي", "تخطيط عمران", "أوتوكاد", "بناء"]
        },
        {
          "name": "هندسة الميكانيكا والكهرباء",
          "query": "subject:(mechanical OR electrical engineering) OR (هندسة كهربائية)",
          "keywords": ["دوائر إلكترونية", "طاقة", "محركات", "صيانة", "روبوتات"]
        },
        {
          "name": "هندسة البرمجيات",
          "query": "subject:(software engineering OR computer science) OR (هندسة برمجيات)",
          "keywords": ["خوارزميات", "هياكل بيانات", "أنماط التصميم", "اختبار البرمجيات"]
        },
      ]
    },

    // ================= 22. الاقتصاد والتجارة العالمية =================
    {
      "id": "global_economy",
      "name": "الاقتصاد العالمي",
      "icon": Icons.public_rounded,
      "color": const Color(0xFFBF360C), // Deep Orange
      "subCategories": [
        {
          "name": "التحليل المالي والأسهم",
          "query": "subject:(stock market OR financial analysis) OR (تحليل مالي)",
          "keywords": ["تداول", "بورصة", "أسهم وسندات", "فوركس", "إدارة مخاطر"]
        },
        {
          "name": "الاقتصاد الكلي والجزئي",
          "query": "subject:(macroeconomics OR microeconomics) OR (علم الاقتصاد)",
          "keywords": ["تضخم", "تجارة دولية", "بنوك مركزية", "تنمية اقتصادية"]
        },
        {
          "name": "المحاسبة والتدقيق",
          "query": "subject:(accounting OR auditing) OR (محاسبة)",
          "keywords": ["ضرائب", "ميزانية", "دفاتر محاسبية", "معايير دولية"]
        },
      ]
    },

    // ================= 23. العلوم الاجتماعية والإنسانية =================
    {
      "id": "social_sciences",
      "name": "العلوم الإنسانية",
      "icon": Icons.groups_3_rounded,
      "color": const Color(0xFF512DA8), // Deep Purple
      "subCategories": [
        {
          "name": "علم الاجتماع",
          "query": "subject:(sociology) OR (علم الاجتماع)",
          "keywords": ["مجتمعات", "تغير اجتماعي", "أنثروبولوجيا", "ظواهر اجتماعية"]
        },
        {
          "name": "التربية وطرق التدريس",
          "query": "subject:(education OR teaching methods) OR (طرق التدريس)",
          "keywords": ["مناهج", "توجيه تربوي", "تعلم نشط", "إدارة مدرسية"]
        },
        {
          "name": "علم النفس الاجتماعي",
          "query": "subject:(social psychology) OR (علم النفس الاجتماعي)",
          "keywords": ["سلوك", "تفاعل", "قيادة", "تأثير الجماعة"]
        },
      ]
    },

    // ================= 24. الفلك والفضاء (للباحثين عن الإلهام) =================
    {
      "id": "space_astronomy",
      "name": "الفضاء والكون",
      "icon": Icons.auto_awesome_rounded,
      "color": const Color(0xFF0D47A1), // Dark Blue
      "subCategories": [
        {
          "name": "علم الفلك",
          "query": "subject:(astronomy OR astrophysics) OR (علم الفلك)",
          "keywords": ["نجوم", "مجرات", "ثقوب سوداء", "تلسكوب", "ناسا"]
        },
        {
          "name": "رحلات الفضاء",
          "query": "subject:(space exploration) OR (رحلات الفضاء)",
          "keywords": ["مركبات فضائية", "أقمار صناعية", "محطة الفضاء الدولية"]
        },
      ]
    },

    // ================= 25. قسم خاص: المخطوطات والكتب النادرة =================
    {
      "id": "manuscripts",
      "name": "المخطوطات والنوادر",
      "icon": Icons.history_edu_rounded,
      "color": const Color(0xFF3E2723), // Dark Brown
      "subCategories": [
        {
          "name": "مخطوطات قديمة",
          "query": "subject:(manuscripts) OR (مخطوطات)",
          "keywords": ["مخطوطات عربية", "تراث قديم", "خط يد", "تحقيق كتب"]
        },
        {
          "name": "كتب نادرة",
          "query": "subject:(rare books) OR (كتب نادرة)",
          "keywords": ["طبعات قديمة", "نوادر الكتب", "مجموعات خاصة"]
        },
      ]
    },

    // ================= 26. قسم خاص: فلسطين والقضية (لأنك ابن غزة) =================
    {
      "id": "palestine",
      "name": "فلسطين والقضية",
      "icon": Icons.location_on_rounded, // يمكنك استبداله بأيقونة مخصصة
      "color": const Color(0xFF1B5E20), // Dark Green (Olive)
      "subCategories": [
        {
          "name": "تاريخ فلسطين",
          "query": "subject:(Palestine history) OR (تاريخ فلسطين)",
          "keywords": ["القدس", "النكبة", "تراث فلسطيني", "جغرافيا فلسطين"]
        },
        {
          "name": "أدب المقاومة",
          "query": "subject:(Palestinian literature) OR (أدب المقاومة)",
          "keywords": ["شعر المقاومة", "غسان كنفاني", "محمود درويش", "روايات فلسطينية"]
        },
      ]
    },
    // ================= 27. تقنيات المستقبل والـ AI المتقدم =================
    {
      "id": "future_tech",
      "name": "تقنيات المستقبل",
      "icon": Icons.psychology_alt_rounded,
      "color": const Color(0xFF00B8D4), // Bright Cyan
      "subCategories": [
        {
          "name": "النماذج اللغوية الكبيرة",
          "query": "(LLM) OR (ChatGPT) OR (Gemini AI) OR (Prompt Engineering)",
          "keywords": ["الذكاء الاصطناعي التوليدي", "هندسة الأوامر", "أتمتة", "GPT-4"]
        },
        {
          "name": "الواقع المعزز والافتراضي",
          "query": "subject:(Augmented Reality OR Virtual Reality) OR (VR/AR)",
          "keywords": ["ميتفيرس", "نظارات ذكية", "محاكاة", "تفاعل إنساني حاسوبي"]
        },
        {
          "name": "الحوسبة السحابية",
          "query": "subject:(Cloud Computing OR AWS OR Azure) OR (الحوسبة السحابية)",
          "keywords": ["خوادم", "استضافة", "قواعد بيانات سحابية", "Docker", "Kubernetes"]
        },
      ]
    },

    // ================= 28. العلوم العسكرية والاستراتيجية =================
    {
      "id": "military_strategy",
      "name": "العلوم الاستراتيجية",
      "icon": Icons.military_tech_rounded,
      "color": const Color(0xFF3E2723), // Deep Brown
      "subCategories": [
        {
          "name": "الفن العسكري والحروب",
          "query": "subject:(Military history OR Strategy) OR (حروب تاريخية)",
          "keywords": ["تكتيكات", "صراعات دولية", "أسلحة", "دفاع", "تاريخ الحروب"]
        },
        {
          "name": "الأمن القومي والاستخبارات",
          "query": "subject:(National security OR Intelligence) OR (الأمن القومي)",
          "keywords": ["تجسس", "عمليات سرية", "تحليل معلومات", "حروب سيبرانية"]
        },
        {
          "name": "إدارة الأزمات والكوارث",
          "query": "subject:(Crisis management) OR (إدارة الأزمات)",
          "keywords": ["طوارئ", "إغاثة", "تخطيط استراتيجي", "تنبؤ"]
        },
      ]
    },

    // ================= 29. العلوم الطبيعية التطبيقية =================
    {
      "id": "applied_science",
      "name": "العلوم التطبيقية",
      "icon": Icons.science_rounded,
      "color": const Color(0xFF558B2F), // Light Green Dark
      "subCategories": [
        {
          "name": "الجيولوجيا وعلوم الأرض",
          "query": "subject:(Geology OR Earth science) OR (جيولوجيا)",
          "keywords": ["زلازل", "براكين", "ثروات معدنية", "مناخ", "تكوين الأرض"]
        },
        {
          "name": "الكيمياء والصناعة",
          "query": "subject:(Chemistry OR Chemical engineering) OR (كيمياء)",
          "keywords": ["مختبرات", "بتروكيماويات", "أدوية", "تفاعلات كيميائية"]
        },
        {
          "name": "الرياضيات التطبيقية",
          "query": "subject:(Mathematics OR Calculus) OR (رياضيات)",
          "keywords": ["إحصاء", "احتمالات", "منطق رياضي", "هندسة تحليلية"]
        },
      ]
    },

    // ================= 30. الفنون والمهارات الرقمية الحديثة =================
    {
      "id": "digital_skills",
      "name": "المهارات الرقمية",
      "icon": Icons.computer_rounded,
      "color": const Color(0xFF673AB7), // Deep Purple
      "subCategories": [
        {
          "name": "التسويق الرقمي",
          "query": "subject:(Digital marketing OR SEO) OR (تسويق إلكتروني)",
          "keywords": ["سيو", "إعلانات جوجل", "تحليل بيانات", "تجارة إلكترونية"]
        },
        {
          "name": "العمل الحر عبر الإنترنت",
          "query": "(freelancing) OR (remote work) OR (العمل الحر)",
          "keywords": ["أب ورك", "مستقل", "خمسات", "إدارة مشاريع", "ربح من الإنترنت"]
        },
        {
          "name": "الإنتاج الصوتي والبودكاست",
          "query": "subject:(Audio production OR Podcast) OR (بودكاست)",
          "keywords": ["هندسة صوتية", "تسجيل", "إلقاء صوتي", "معدات صوت"]
        },
      ]
    },

    // ================= 31. قسم خاص: السير والمذكرات الشخصية =================
    {
      "id": "biographies",
      "name": "سير ومذكرات",
      "icon": Icons.person_search_rounded,
      "color": const Color(0xFF283593), // Indigo
      "subCategories": [
        {
          "name": "سير العظماء والقادة",
          "query": "subject:(Biography) AND (Leaders) OR (سير ذاتية)",
          "keywords": ["مذكرات", "تاريخ شخصي", "قصص نجاح", "عظماء التاريخ"]
        },
        {
          "name": "مذكرات أدبية",
          "query": "subject:(Literary memoirs) OR (مذكرات أدباء)",
          "keywords": ["يوميات", "رسائل", "ذكريات", "حياة الكتاب"]
        },
      ]
    },
    // ================= 32. العلوم الإنسانية العميقة =================
    {
      "id": "humanities_deep",
      "name": "العلوم الإنسانية",
      "icon": Icons.account_tree_rounded,
      "color": const Color(0xFF4E342E), // Brown Dark
      "subCategories": [
        {
          "name": "الأنثروبولوجيا",
          "query": "subject:(Anthropology) OR (علم الإنسان)",
          "keywords": ["ثقافات الشعوب", "تطور مجتمعات", "أعراف", "إثنوغرافيا"]
        },
        {
          "name": "اللسانيات واللغويات",
          "query": "subject:(Linguistics) OR (علم اللسانيات)",
          "keywords": ["صوتيات", "دلالة", "تراكيب لغوية", "نشأة اللغات"]
        },
        {
          "name": "الأركيولوجيا (الآثار)",
          "query": "subject:(Archaeology) OR (علم الآثار)",
          "keywords": ["تنقيب", "نقوش قديمة", "مومياوات", "كنوز غارقة"]
        },
      ]
    },

    // ================= 33. الاستدامة والعلوم البيئية المتقدمة =================
    {
      "id": "sustainability",
      "name": "الاستدامة والبيئة",
      "icon": Icons.recycling_rounded,
      "color": const Color(0xFF2E7D32), // Green Shade
      "subCategories": [
        {
          "name": "الطاقة المتجددة",
          "query": "subject:(Renewable Energy OR Solar Energy) OR (طاقة شمسية)",
          "keywords": ["طاقة الرياح", "هيدروجين أخضر", "كهرباء مستدامة"]
        },
        {
          "name": "العمارة الخضراء",
          "query": "subject:(Green Architecture OR Sustainable Design)",
          "keywords": ["مباني ذكية", "توفير الطاقة", "مواد بناء صديقة للبيئة"]
        },
        {
          "name": "إعادة التدوير",
          "query": "subject:(Recycling OR Waste Management)",
          "keywords": ["نفايات", "سماد عضوي", "حماية المحيطات"]
        },
      ]
    },

    // ================= 34. الجغرافيا وأدب الرحلات =================
    {
      "id": "geography_travel",
      "name": "الجغرافيا والرحلات",
      "icon": Icons.explore_rounded,
      "color": const Color(0xFF0277BD), // Light Blue Dark
      "subCategories": [
        {
          "name": "الجغرافيا السياسية",
          "query": "subject:(Geopolitics) OR (الجغرافيا السياسية)",
          "keywords": ["حدود", "خرائط", "توزيع سكاني", "ثروات طبيعية"]
        },
        {
          "name": "أدب الرحلات",
          "query": "subject:(Travel Literature) OR (أدب الرحلات)",
          "keywords": ["ابن بطوطة", "رحالة", "وصف بلدان", "استكشاف"]
        },
        {
          "name": "الطقس والمناخ",
          "query": "subject:(Meteorology OR Climate)",
          "keywords": ["أرصاد جوية", "أعاصير", "احتباس حراري"]
        },
      ]
    },

    // ================= 35. الإدارة اللوجستية والمشاريع =================
    {
      "id": "logistics_management",
      "name": "الإدارة واللوجستيات",
      "icon": Icons.inventory_2_rounded,
      "color": const Color(0xFF37474F), // Blue Grey
      "subCategories": [
        {
          "name": "سلاسل الإمداد",
          "query": "subject:(Supply Chain Management) OR (سلاسل الإمداد)",
          "keywords": ["لوجستيات", "شحن وتفريغ", "مخازن", "توزيع"]
        },
        {
          "name": "إدارة المشاريع (PMP)",
          "query": "subject:(Project Management) OR (إدارة مشاريع)",
          "keywords": ["أجايل", "سكرم", "تخطيط مهام", "إدارة جودة"]
        },
        {
          "name": "الموارد البشرية (HR)",
          "query": "subject:(Human Resources) OR (الموارد البشرية)",
          "keywords": ["توظيف", "تدريب وتطوير", "ثقافة مؤسسية"]
        },
      ]
    },

    // ================= 36. قسم النقد والتحليل الأدبي =================
    {
      "id": "literary_criticism",
      "name": "النقد والتحليل",
      "icon": Icons.rate_review_rounded,
      "color": const Color(0xFF880E4F), // Maroon
      "subCategories": [
        {
          "name": "النقد الأدبي",
          "query": "subject:(Literary Criticism) OR (النقد الأدبي)",
          "keywords": ["بنيوية", "تفكيكية", "نقد الرواية", "مناهج نقدية"]
        },
        {
          "name": "البلاغة والأسلوبية",
          "query": "subject:(Rhetoric OR Stylistics) OR (البلاغة)",
          "keywords": ["استعارة", "كناية", "علم المعاني", "إعجاز لغوي"]
        },
      ]
    },
    // ================= 37. الذكاء الاصطناعي للأعمال (AI for Business) =================
    {
      "id": "ai_business",
      "name": "الذكاء الاصطناعي للأعمال",
      "icon": Icons.insights_rounded,
      "color": const Color(0xFF006064), // Dark Cyan
      "subCategories": [
        {
          "name": "أتمتة العمليات (RPA)",
          "query": "(Robotic Process Automation) OR (أتمتة العمليات)",
          "keywords": ["كفاءة", "توفير وقت", "سير العمل", "أدوات الذكاء الاصطناعي"]
        },
        {
          "name": "تحليل البيانات الضخمة",
          "query": "subject:(Big Data Analytics) OR (بيانات ضخمة)",
          "keywords": ["توقعات", "سلوك المستهلك", "إحصاء متقدم", "تعدين البيانات"]
        },
        {
          "name": "أخلاقيات الذكاء الاصطناعي",
          "query": "subject:(AI Ethics) OR (أخلاقيات الذكاء الاصطناعي)",
          "keywords": ["تحيز خوارزمي", "خصوصية", "قوانين الذكاء الاصطناعي"]
        },
      ]
    },

    // ================= 38. العلوم الجنائية والتحقيق =================
    {
      "id": "forensic_science",
      "name": "العلوم الجنائية",
      "icon": Icons.fingerprint_rounded,
      "color": const Color(0xFF311B92), // Deep Indigo
      "subCategories": [
        {
          "name": "علم الجريمة (Criminology)",
          "query": "subject:(Criminology) OR (علم الجريمة)",
          "keywords": ["سلوك إجرامي", "دوافع", "إصلاح وتأهيل", "سجون"]
        },
        {
          "name": "الأدلة الجنائية",
          "query": "subject:(Forensic Evidence) OR (أدلة جنائية)",
          "keywords": ["مسرح الجريمة", "بصمات", "تحليل DNA", "سموم جنائية"]
        },
        {
          "name": "علم النفس الجنائي",
          "query": "subject:(Forensic Psychology) OR (علم النفس الجنائي)",
          "keywords": ["تحقيق", "استجواب", "كذب", "بروفايل المجرم"]
        },
      ]
    },

    // ================= 39. السينما والفنون البصرية =================
    {
      "id": "cinema_arts",
      "name": "السينما والصورة",
      "icon": Icons.movie_filter_rounded,
      "color": const Color(0xFFE91E63), // Pink Accent
      "subCategories": [
        {
          "name": "صناعة الأفلام",
          "query": "subject:(Filmmaking OR Cinematography) OR (صناعة الأفلام)",
          "keywords": ["إخراج", "تصوير سينمائي", "إنتاج", "إضاءة"]
        },
        {
          "name": "كتابة السيناريو",
          "query": "subject:(Screenwriting) OR (كتابة السيناريو)",
          "keywords": ["حبكة", "حوار", "بناء الشخصية", "مشاهد"]
        },
        {
          "name": "تاريخ السينما",
          "query": "subject:(Film History) OR (تاريخ السينما)",
          "keywords": ["كلاسيكيات", "نقد سينمائي", "هوليوود", "مهرجانات"]
        },
      ]
    },

    // ================= 40. اللياقة والأداء البدني المتقدم =================
    {
      "id": "sports_science",
      "name": "علوم الرياضة",
      "icon": Icons.fitness_center_rounded,
      "color": const Color(0xFF1B5E20), // Deep Green
      "subCategories": [
        {
          "name": "التغذية الرياضية",
          "query": "subject:(Sports Nutrition) OR (تغذية رياضية)",
          "keywords": ["مكملات", "بروتين", "طاقة", "إنقاص وزن"]
        },
        {
          "name": "الإصابات والتأهيل",
          "query": "subject:(Sports Injuries OR Physiotherapy) OR (علاج طبيعي)",
          "keywords": ["رباط صليبي", "تدليك", "وقاية", "تمارين علاجية"]
        },
        {
          "name": "علم النفس الرياضي",
          "query": "subject:(Sports Psychology) OR (علم النفس الرياضي)",
          "keywords": ["تركيز", "إصرار", "روح الفريق", "منافسة"]
        },
      ]
    },

    // ================= 41. قسم خاص: المهارات اليدوية والحرف =================
    {
      "id": "crafts",
      "name": "الحرف والمهارات",
      "icon": Icons.construction_rounded,
      "color": const Color(0xFF795548), // Brown
      "subCategories": [
        {
          "name": "النجارة والأشغال اليدوية",
          "query": "subject:(Woodworking OR Crafts) OR (نجارة)",
          "keywords": ["أثاث", "خشب", "أدوات", "دهانات"]
        },
        {
          "name": "تصليح الأجهزة",
          "query": "subject:(Maintenance OR Repair) OR (صيانة)",
          "keywords": ["كهرباء", "سباكة", "صيانة سيارات", "إصلاح منزلي"]
        },
      ]
    },
  ];

  // دالة مساعدة للحصول على كلمات البحث العشوائية لقسم معين (للـ Suggestions)
  static List<String> getKeywordsForCategory(String subCatName) {
    for (var cat in allCategories) {
      for (var sub in cat['subCategories']) {
        if (sub['name'] == subCatName) {
          return List<String>.from(sub['keywords']);
        }
      }
    }
    return [];
  }
}