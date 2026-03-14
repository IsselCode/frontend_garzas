import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:window_manager/window_manager.dart';

import '../../../commons/text_back_button.dart';
import '../../../core/app/consts.dart';
import '../pages/user_management/create_user_page.dart';
import '../pages/user_management/update_user_page.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {

  PageController pageController = PageController();
  TabSwitcherAlignStates state = TabSwitcherAlignStates.left;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            //* Body
            Center(
              child: Container(
                width: 455,
                height: 589,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 30,
                  children: [

                    // Cabecera
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Flex(
                        spacing: 30,
                        direction: Axis.vertical,
                        children: [
                          IsselAssetContainer(asset: AppAssets.logo, width: 64, height: 64,),
                          IsselTabSwitcher(
                            state: state,
                            leftText: "Crear",
                            rightText: "Actualizar",
                            onChanged: changePage,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ],
                      ),
                    ),

                    // Paginas
                    Expanded(
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: pageController,
                        children: [
                          CreateUserPage(),
                          UpdateUserPage()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            //* AppBar
            Positioned(
              top: kWindowCaptionHeight,
              left: 10,
              child: TextBackButton()
            ),

          ],
        ),
      ),
    );
  }

  void changePage(TabSwitcherAlignStates value) {

    Duration duration = Duration(milliseconds: 350);
    Curve curve = Curves.linearToEaseOut;

    switch (value) {
      case TabSwitcherAlignStates.left:
        pageController.animateToPage(0, duration: duration, curve: curve);
      case TabSwitcherAlignStates.right:
        pageController.animateToPage(1, duration: duration, curve: curve);
    }

    state = value;
    setState(() {});

  }

}
