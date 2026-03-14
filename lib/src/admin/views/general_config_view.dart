import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';

class GeneralConfigView extends StatelessWidget {
  const GeneralConfigView({super.key});

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
