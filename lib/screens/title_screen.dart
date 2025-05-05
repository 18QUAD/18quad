import 'package:flutter/material.dart';
import 'package:rennda_app/screens/home_screen.dart';
import 'package:rennda_app/widgets/app_scaffold.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '18QUAD',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: const Image(
                image: AssetImage('assets/images/title_image.png'),
                width: 240,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const _StartButton(),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      child: const Text('START'),
    );
  }
}
