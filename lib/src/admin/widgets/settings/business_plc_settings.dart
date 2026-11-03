import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class BusinessPlcSettings extends StatelessWidget {
  const BusinessPlcSettings({
    super.key,
    required this.formKey,
    required this.controller,
    required this.validator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'IP y puerto del PLC',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        IsselTextFormField(
          height: 48,
          hintText: 'IP:PUERTO',
          prefixIcon: Icons.settings_ethernet_outlined,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
          controller: controller,
          validator: validator,
        ),
      ],
    ),
  );
}
