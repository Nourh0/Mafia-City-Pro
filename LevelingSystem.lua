[
  {
    "status": "success",
    "file_created": "Modules/LevelingSystem.lua",
    "module_name": "نظام المستويات والمكافآت (LevelingSystem)",
    "summary": "تم إنشاء نظام التقدم (Progression System) الذي يربط اللعب بالجوائز المالية والترقيات، مع توفير ميزات تنافسية للمشتركين لضمان سرعة تطور حساباتهم.",
    "analysis": {
      "leveling_mechanics": {
        "base_xp": "500 XP لكل مستوى لضمان توازن التحدي.",
        "reward": "منح 100 عملة مجانية عند كل ترقية لدفع اللاعبين للاستمرار.",
        "judge_lock": "تقييد دور القاضي حتى المستوى 10، مما يرفع من هيبة الدور ويضمن أن من يشغله لاعب خبير."
      },
      "subscription_synergy": {
        "elite_boost": "مضاعفة الخبرة 2x لمشتركي البريميوم (250 ريال).",
        "medium_boost": "زيادة الخبرة 1.5x لمشتركي البلاتينيوم (150 ريال)."
      },
      "data_handling": "يستخدم النظام الـ Attributes لتخزين 'Coins' و 'XP' و 'Level' بشكل مباشر على اللاعب لسهولة الوصول إليها."
    },
    "technical_context": "هذا الملف يكمل نظام الأدوار (RoleManager)؛ حيث لن يتم ترشيح أي لاعب لدور القاضي ما لم يكن لديه السمة 'CanBeJudge' التي يتم تفعيلها هنا عند المستوى 10.",
    "next_step": {
      "action": "إنشاء ملف إدارة السيرفر (ServerMain.lua)",
      "purpose": "نحتاج الآن لملف يجمع (Leveling, Membership, Roles, UI) ليعملوا معاً فور دخول اللاعب للمدينة."
    }
  }
]