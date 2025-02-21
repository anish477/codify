
import 'package:codify/gamification/lives.dart';
import 'package:codify/gamification/lives_service.dart';
import 'package:codify/services/auth.dart';
import 'package:flutter/material.dart';

class LivesProvider extends ChangeNotifier{
      final LivesService _livesService=LivesService();
      final AuthService _authService=AuthService();

      Lives? _lives;

      Lives? get lives=>_lives;

     LivesProvider() {
           _initializeUser();
           notifyListeners();
     }


Future<void> _initializeUser() async {
      final user = await _authService.getUID();
      if (user != null) {
            await _livesService.init(user);
            _lives = _livesService.getLives();
            notifyListeners();
      }
      notifyListeners();

}

      void decreaseLives() {
            if (_lives != null && _lives!.currentLives > 0) {
                  _lives!.currentLives--;
                  notifyListeners();
            }
            notifyListeners();
      }



      void setLives(int lives){
            if(_lives!=null){
                  _lives!.currentLives=lives;
                  notifyListeners();
            }
      }





}