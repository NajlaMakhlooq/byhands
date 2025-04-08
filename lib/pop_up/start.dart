import 'dart:async';
import 'package:byhands_application/pages/start_pages/login.dart';
import 'package:flutter/material.dart';

class Start extends StatefulWidget {
  const Start({
    super.key,
  });

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();
    _startTimer();
    _animateImage();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  void _animateImage() {
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              child: Image.asset(
                'assets/logo.png', width: 200, // Adjust width
                height: 200,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              child: const Text(
                'BY Hands App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
