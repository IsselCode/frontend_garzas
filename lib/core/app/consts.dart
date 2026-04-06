import 'package:flutter/material.dart';

class AppLotties {
  static const _baseLotties = "assets/lotties";

  static const scan =
      "$_baseLotties/scan.json"; // https://lottiefiles.com/es/free-animation/document-ocr-scan-xjHvcgGQ7G
  static const glass_water =
      "$_baseLotties/glass_water.json"; // https://lottiefiles.com/free-animation/water-KjMVMduwqB
  static const water_indicator =
      "$_baseLotties/water_indicator.json"; // https://lottiefiles.com/free-animation/water-KjMVMduwqB
}

class AppAssets {
  static const _baseImages = "assets/images";

  static const logo = "$_baseImages/pabn.png";
  static const logo2 = "$_baseImages/rubi.png";

  static const configs = "$_baseImages/configs.png";
  static const customers = "$_baseImages/customers.png";
  static const statistics = "$_baseImages/statistics.png";
  static const users = "$_baseImages/users.png";

  static const admin = "$_baseImages/admin.png";
  static const cashRegister = "$_baseImages/cash_register.png";
  static const waterTank = "$_baseImages/water_tank.png";

  static const cash = "$_baseImages/cash.png";
  static const card = "$_baseImages/card.png";
  static const check = "$_baseImages/check.png";
  static const credit = "$_baseImages/loan.png";
}

class AppColors {
  static const darkBackground = Color(0xff0F101B);
  static const darkBackSurface = Color(0xff272832);
  static const lightBackground = Color(0xffE5ECF4);
  static const whiteBackSurface = Color(0xfff6f8fa);

  static const grey = Color(0xff727385);
  static const white = Color(0xffFFFFFF);
  static const black = Color(0xff000000);
  static const red = Colors.red;

  static const primary = Color(0xff0F52FF);
  static const secondary = Color(0xff1A3A9F);
  static const darkPrimary = Color(0xff0046ff);
}

class AppGradients {
  static const primaryToSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
    stops: [0.10, 0.85],
  );
}
