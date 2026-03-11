import 'package:flutter/material.dart';
import 'package:frontend_garzas/commons/text_back_button.dart';
import 'package:window_manager/window_manager.dart';

class StartOrderView extends StatelessWidget {
  const StartOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: kWindowCaptionHeight),
          child: TextBackButton(),
        ),
      ),
      body: Center(
        child: Text("Comenzar Orden"),
      ),
    );
  }
}
