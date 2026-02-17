class DashboardData {
  final UserOverview userOverview;
  final CurrentLearning currentLearning;
  final RecentActivity recentActivity;
  final QuickStats quickStats;
  final Recommendations recommendations;

  DashboardData({
    required this.userOverview,
    required this.currentLearning,
    required this.recentActivity,
    required this.quickStats,
    required this.recommendations,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      userOverview: UserOverview.fromJson(json['user_overview'] ?? {}),
      currentLearning: CurrentLearning.fromJson(json['current_learning'] ?? {}),
      recentActivity: RecentActivity.fromJson(json['recent_activity'] ?? {}),
      quickStats: QuickStats.fromJson(json['quick_stats'] ?? {}),
      recommendations: Recommendations.fromJson(json['recommendations'] ?? {}),
    );
  }
}

class UserOverview {
  final String name;
  final int totalChapters;
  final int completedChapters;
  final CurrentChapter? currentChapter;
  final double overallProgressPercentage;
  final double totalScoreAverage;
  final int streakDays;
  final DateTime? lastActivity;
  final int totalMaterialsCompleted;
  final int totalMaterialsAvailable;
  final bool hasCompletedPretest;
  final double pretestScore;

  UserOverview({
    required this.name,
    required this.totalChapters,
    required this.completedChapters,
    this.currentChapter,
    required this.overallProgressPercentage,
    required this.totalScoreAverage,
    required this.streakDays,
    this.lastActivity,
    required this.totalMaterialsCompleted,
    required this.totalMaterialsAvailable,
    required this.hasCompletedPretest,
    required this.pretestScore,
  });

  factory UserOverview.fromJson(Map<String, dynamic> json) {
    return UserOverview(
      name: json['name'] ?? '',
      totalChapters: json['total_chapters'] ?? 0,
      completedChapters: json['completed_chapters'] ?? 0,
      currentChapter: json['current_chapter'] != null 
          ? CurrentChapter.fromJson(json['current_chapter']) 
          : null,
      overallProgressPercentage: (json['overall_progress_percentage'] ?? 0).toDouble(),
      totalScoreAverage: (json['total_score_average'] ?? 0).toDouble(),
      streakDays: json['streak_days'] ?? 0,
      lastActivity: json['last_activity'] != null 
          ? DateTime.tryParse(json['last_activity']) 
          : null,
      totalMaterialsCompleted: json['total_materials_completed'] ?? 0,
      totalMaterialsAvailable: json['total_materials_available'] ?? 0,
      hasCompletedPretest: json['has_completed_pretest'] ?? false,
      pretestScore: (json['pretest_score'] ?? 0).toDouble(),
    );
  }

  double get chaptersProgress => totalChapters > 0 ? completedChapters / totalChapters : 0.0;
  double get materialsProgress => totalMaterialsAvailable > 0 ? totalMaterialsCompleted / totalMaterialsAvailable : 0.0;
}

class CurrentChapter {
  final int id;
  final String name;

  CurrentChapter({
    required this.id,
    required this.name,
  });

  factory CurrentChapter.fromJson(Map<String, dynamic> json) {
    return CurrentChapter(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CurrentLearning {
  final ActiveChapter? activeChapter;
  final NextMaterial? nextMaterial;

  CurrentLearning({
    this.activeChapter,
    this.nextMaterial,
  });

  factory CurrentLearning.fromJson(Map<String, dynamic> json) {
    return CurrentLearning(
      activeChapter: json['active_chapter'] != null 
          ? ActiveChapter.fromJson(json['active_chapter']) 
          : null,
      nextMaterial: json['next_material'] != null 
          ? NextMaterial.fromJson(json['next_material']) 
          : null,
    );
  }
}

class ActiveChapter {
  final int id;
  final String name;
  final String description;
  final double progressPercentage;
  final int materialsCompleted;
  final int materialsTotal;

  ActiveChapter({
    required this.id,
    required this.name,
    required this.description,
    required this.progressPercentage,
    required this.materialsCompleted,
    required this.materialsTotal,
  });

  factory ActiveChapter.fromJson(Map<String, dynamic> json) {
    return ActiveChapter(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
      materialsCompleted: json['materials_completed'] ?? 0,
      materialsTotal: json['materials_total'] ?? 0,
    );
  }

  double get progress => materialsTotal > 0 ? materialsCompleted / materialsTotal : 0.0;
}

class NextMaterial {
  final int id;
  final String name;
  final String type;
  final bool isUnlocked;

  NextMaterial({
    required this.id,
    required this.name,
    required this.type,
    required this.isUnlocked,
  });

  factory NextMaterial.fromJson(Map<String, dynamic> json) {
    return NextMaterial(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      isUnlocked: json['is_unlocked'] ?? false,
    );
  }
}

class RecentActivity {
  final String? lastCompletedMaterial;
  final List<String> completedMaterials;
  final List<int> recentScores;
  final AssessmentsThisWeek assessmentsThisWeek;
  final int materialsCompletedThisWeek;

  RecentActivity({
    this.lastCompletedMaterial,
    required this.completedMaterials,
    required this.recentScores,
    required this.assessmentsThisWeek,
    required this.materialsCompletedThisWeek,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      lastCompletedMaterial: json['last_completed_material'],
      completedMaterials: List<String>.from(json['completed_materials'] ?? []),
      recentScores: List<int>.from(json['recent_scores'] ?? []),
      assessmentsThisWeek:
          AssessmentsThisWeek.fromJson(json['assessments_this_week'] ?? {}),
      materialsCompletedThisWeek: json['materials_completed_this_week'] ?? 0,
    );
  }

  double get averageRecentScore {
    if (recentScores.isEmpty) return 0.0;
    return recentScores.reduce((a, b) => a + b) / recentScores.length;
  }
}

class AssessmentsThisWeek {
  final int total;
  final int finalTests;
  final int quizzes;

  AssessmentsThisWeek({
    required this.total,
    required this.finalTests,
    required this.quizzes,
  });

  factory AssessmentsThisWeek.fromJson(Map<String, dynamic> json) {
    return AssessmentsThisWeek(
      total: json['total'] ?? 0,
      finalTests: json['final_tests'] ?? 0,
      quizzes: json['quizzes'] ?? 0,
    );
  }
}

class QuickStats {
  final String totalStudyTime;
  final Assessments assessments;
  final double aiFeedbackScore;
  final String chapterCompletionRate;

  QuickStats({
    required this.totalStudyTime,
    required this.assessments,
    required this.aiFeedbackScore,
    required this.chapterCompletionRate,
  });

  factory QuickStats.fromJson(Map<String, dynamic> json) {
    return QuickStats(
      totalStudyTime: json['total_study_time'] ?? '0h 0m',
      assessments: Assessments.fromJson(json['assessments'] ?? {}),
      aiFeedbackScore: (json['ai_feedback_score'] ?? 0).toDouble(),
      chapterCompletionRate: json['chapter_completion_rate'] ?? '0%',
    );
  }
}

class Assessments {
  final FinalTests finalTests;
  final Quizzes quizzes;
  final int totalExcludingAi;

  Assessments({
    required this.finalTests,
    required this.quizzes,
    required this.totalExcludingAi,
  });

  factory Assessments.fromJson(Map<String, dynamic> json) {
    return Assessments(
      finalTests: FinalTests.fromJson(json['final_tests'] ?? {}),
      quizzes: Quizzes.fromJson(json['quizzes'] ?? {}),
      totalExcludingAi: json['total_excluding_ai'] ?? 0,
    );
  }
}

class FinalTests {
  final int total;
  final int passed;
  final double passRate;

  FinalTests({
    required this.total,
    required this.passed,
    required this.passRate,
  });

  factory FinalTests.fromJson(Map<String, dynamic> json) {
    return FinalTests(
      total: json['total'] ?? 0,
      passed: json['passed'] ?? 0,
      passRate: (json['pass_rate'] ?? 0).toDouble(),
    );
  }
}

class Quizzes {
  final int total;

  Quizzes({
    required this.total,
  });

  factory Quizzes.fromJson(Map<String, dynamic> json) {
    return Quizzes(
      total: json['total'] ?? 0,
    );
  }
}

class Recommendations {
  final List<String> nextActions;
  final List<String> improvementAreas;
  final List<String> strengths;

  Recommendations({
    required this.nextActions,
    required this.improvementAreas,
    required this.strengths,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      nextActions: List<String>.from(json['next_actions'] ?? []),
      improvementAreas: List<String>.from(json['improvement_areas'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
    );
  }
}