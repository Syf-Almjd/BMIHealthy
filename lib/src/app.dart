import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bmihealthy/src/presentation/Cubits/theme_bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/utils/managers/app_constants.dart';
import 'data/local/localData_cubit/local_data_cubit.dart';
import 'domain/NaviController.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LocalDataCubit(),
        ),
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return AdaptiveTheme(
            light: ThemeState.lightTheme.themeData,
            dark: ThemeState.darkTheme.themeData,
            debugShowFloatingThemeButton: false,
            initial: AdaptiveThemeMode.light,
            builder: (theme, darkTheme) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppConstants.appTitle,
              theme: state.themeData,
              home: const NavigationController(),
            ),
          );
        },
      ),
    );
  }
}
