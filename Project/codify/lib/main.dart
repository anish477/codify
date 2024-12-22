import 'package:flutter/material.dart';
import 'package:codify/pages/splash.dart';
import 'package:codify/pages/home.dart';
import 'package:codify/pages/login.dart';
import 'package:codify/pages/signup.dart';

void main()=>runApp(MaterialApp(

  routes: {
    '/': (context) =>  Splash(),
    '/login': (context) =>  Login(),
    '/signup': (context) =>  Signup(),
  },

));