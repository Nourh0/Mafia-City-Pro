{
  "status": "success",
  "file_created": "Modules/RoleManager.lua",
  "module_name": "مدير توزيع الأدوار المتقدم (RoleManager)",
  "summary": "تم إنشاء نظام توزيع الأدوار الذكي الذي يعطي أولوية برمجية للمشتركين. النظام يستخدم خوارزمية الاحتمالات (60/40) لضمان رضا المشتركين مع الحفاظ على توازن اللعبة.",
  "analysis": {
    "logic_tier_1_premium": {
      "subscription": "Elite (250 SAR)",
      "priority_roles": ["Mafia", "Boss"],
      "probability": "60% للأدوار القيادية، 40% للأدوار العامة."
    },
    "logic_tier_2_platinum": {
      "subscription": "Medium (150 SAR)",
      "priority_roles": ["Judge", "Mafia"],
      "probability": "60% لأدوار القضاء والمافيا، 40% للأدوار العامة."
    },
    "logic_tier_3_guest": {
      "subscription": "Normal (Free)",
      "probability": "توزيع عشوائي عادل بنسبة 100% من قائمة الأدوار المتاحة (Role Pool)."
    }
  },
  "technical_features": {
    "randomization": "يستخدم math.randomseed لضمان عدم تكرار نفس النمط في كل جولة.",
    "attribute_sync": "يتم حفظ الدور في سمة 'CurrentRole' لسهولة استدعائها من قبل نظام الواجهة (UI) أو السيرفر."
  },
  "milestone": "هذا الملف هو المحرك الأساسي الذي سيجعل اللاعبين يرغبون في الاشتراك للحصول على القوة (المافيا والقضاء).",
  "next_step": {
    "action": "تحديث نظام GameManager",
    "instruction": "رائع! الآن لدينا نظام توزيع عادل ومربح في آن واحد. هل ننتقل لدمج هذا النظام في GameManager.lua لتبدأ اللعبة باستخدام هذه الاحتمالات الجديدة؟"
  }
}