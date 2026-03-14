import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:window_manager/window_manager.dart';

class ConfigGarzasView extends StatelessWidget {
  const ConfigGarzasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: kWindowCaptionHeight, left: 10, right: 10, bottom: 10),
        child: Column(
          children: [
            TextBackButton()
          ],
        ),
      ),
    );
  }
}
