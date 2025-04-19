import 'package:codify/provider/lives_provider.dart';
import 'package:codify/provider/profile_provider.dart';
import 'package:codify/provider/streak_provider.dart';

import 'lesson_provider.dart';

class ProviderResetService {
  final LessonProvider lessonProvider;
  final LivesProvider livesProvider;
  final StreakProvider streakProvider;
  final ProfileProvider profileProvider;

  ProviderResetService({
    required this.lessonProvider,
    required this.livesProvider,
    required this.streakProvider,
    required this.profileProvider,
  });

  void resetAllProviders() {
    lessonProvider.reset();
    livesProvider.reset();
    streakProvider.reset();
    profileProvider.reset();
  }
}
