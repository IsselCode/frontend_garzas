import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';

class FinishOrderView extends StatelessWidget {
  const FinishOrderView({super.key});

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
        child: Text("Finish Order View"),
      ),
    );
  }
}
