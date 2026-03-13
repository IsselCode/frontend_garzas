import 'package:flutter/material.dart';

class ButtonContainer extends StatelessWidget {

  final String title;
  final String asset;
  final VoidCallback onTap;

  const ButtonContainer({
    super.key,
    required this.title,
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    //* Theme
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    TextTheme textTheme = theme.textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      mouseCursor: SystemMouseCursors.click,
      onTap: onTap,
      child: Ink(
        width: 200,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colorScheme.surface
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, width: 128, height: 128,),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                )
              )
            )
          ],
        ),
      ),
    );
  }

}
