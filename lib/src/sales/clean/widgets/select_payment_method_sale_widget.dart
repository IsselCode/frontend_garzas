import 'package:flutter/material.dart';

class SelectPaymentMethodSaleWidget extends StatelessWidget {

  final VoidCallback onTap;
  final String image;
  final bool selected;

  const SelectPaymentMethodSaleWidget({
    super.key,
    required this.onTap,
    required this.image,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        hoverColor: colorScheme.surface.withAlpha(50),
        splashColor: colorScheme.surfaceContainer,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: selected ? colorScheme.surface : null,
              borderRadius: BorderRadius.circular(999)
          ),
          padding: EdgeInsets.all(5),
          child: Image.asset(image, width: 64, height: 64,),
        ),
      ),
    );
  }
}
