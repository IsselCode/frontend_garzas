import 'package:flutter/material.dart';

class SelectPaymentMethodWidget extends StatelessWidget {

  final VoidCallback onTap;
  final String image;
  final bool selected;
  final Color color;
  final Color? splashColor;

  const SelectPaymentMethodWidget({
    super.key,
    required this.onTap,
    required this.image,
    required this.selected,
    required this.color,
    this.splashColor,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        hoverColor: color.withAlpha(40),
        splashColor: splashColor ?? color.withAlpha(150),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? color : null,
            borderRadius: BorderRadius.circular(999)
          ),
          padding: EdgeInsets.all(5),
          child: Image.asset(image, width: 64, height: 64,),
        ),
      ),
    );
  }
}
