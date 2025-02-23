import 'package:flutter/material.dart';
import '../gamification/lives.dart';
import '../gamification/lives_service.dart';
import '../services/auth.dart';


class LivesProvider extends ChangeNotifier {
      final LivesService _livesService = LivesService();
      final AuthService _authService = AuthService();
      Lives? _lives;

      Lives? get lives => _lives;

      LivesProvider() {
            _initializeUser();
      }

      Future<void> _initializeUser() async {
            final user = await _authService.getUID();
            if (user != null) {
                  await _livesService.init(user);
                  _lives = _livesService.getLives();
                  notifyListeners();
            }
      }

      void decreaseLives() {
            if (_lives != null && _lives!.currentLives > 0) {
                  _livesService.consumeLife();
                  _lives = _livesService.getLives();
                  notifyListeners();
            }
      }

      void setLives(int lives) {
            if (_lives != null) {
                  _lives!.currentLives = lives;
                  notifyListeners();
            }
      }
}