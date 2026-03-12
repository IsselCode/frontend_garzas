import 'package:frontend_garzas/core/errors/exceptions.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

enum WaterType {

  potable(display: "Potable"),
  pozo(display: "Pozo");

  final String display;
  const WaterType({required this.display});

  static WaterType fromTabSwitcher(TabSwitcherAlignStates state)
    => state == TabSwitcherAlignStates.left ? WaterType.potable : WaterType.pozo;

  static WaterType fromString(String name) {

    switch (name) {
      case "potable":
        return WaterType.potable;
      case "pozo":
        return WaterType.pozo;
      default:
        throw AppException(message: "Tipo de agua inexistente");
    }

  }

}