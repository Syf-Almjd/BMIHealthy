import 'package:flutter/material.dart';

import '../utils/managers/app_constants.dart';
import '../utils/managers/app_values.dart';
import '../utils/styles/app_colors.dart';
import '../utils/styles/app_textstyles.dart';

ThemeData getApplicationTheme() {
  return ThemeData.light().copyWith(
      // main colors of the app
      colorScheme:
          const ColorScheme.light().copyWith(primary: AppColors.primaryColor),
      primaryColorLight: AppColors.primaryColor,
      primaryColor: AppColors.primaryColor,
      hoverColor: AppColors.lowLightPriority,
      backgroundColor: AppColors.white,
      //Text Theme
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: AppConstants.appFontFamily,
          ),
      primaryTextTheme: ThemeData.light().textTheme.apply(
            fontFamily: AppConstants.appFontFamily,
          ),
      //input theme
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        // hint style
        hintStyle: getRegularStyle(color: AppColors.black),

        // label style
        labelStyle: getMediumStyle(color: AppColors.greyDark),
        // error style
        errorStyle: getRegularStyle(color: AppColors.redColor),

        // enabled border
        enabledBorder: OutlineInputBorder(
            // elevated butt
            borderSide: BorderSide(
                color: AppColors.secondaryColor, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),

        // focused border
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.primaryColor, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),

        // error border
        errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.redColor, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),
        // focused error border
        focusedErrorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.primaryColor, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),
      ));
}

ThemeData getDarkApplicationTheme() {
  return ThemeData.dark().copyWith(
      // main colors of the app
      colorScheme:
          const ColorScheme.dark().copyWith(primary: AppColors.secondaryColor),
      hoverColor: AppColors.black,
      primaryColorLight: AppColors.scaffoldColor,
      backgroundColor: AppColors.black,
      scaffoldBackgroundColor: AppColors.black,

      //Text Theme
      textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: AppConstants.appFontFamily,
          ),
      primaryTextTheme: ThemeData.dark().textTheme.apply(
            fontFamily: AppConstants.appFontFamily,
          ),

      //input theme
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        // hint style
        hintStyle: getRegularStyle(color: AppColors.grey),

        // label style
        labelStyle: getMediumStyle(color: AppColors.greyDark),
        // error style
        errorStyle: getRegularStyle(color: AppColors.redColor),

        // enabled border
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),

        // focused border
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.primaryColor, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),

        // error border
        errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.redColor, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),
        // focused error border
        focusedErrorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors.primaryColor, width: AppSize.s1_5),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),
      ));
}
