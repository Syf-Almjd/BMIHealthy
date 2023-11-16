import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Cubits/theme_bloc/theme_bloc.dart';
import '../../Cubits/theme_bloc/theme_event.dart';

class ThemeHeader extends StatefulWidget {
  const ThemeHeader({super.key});

  @override
  State<ThemeHeader> createState() => _ThemeHeaderState();
}

class _ThemeHeaderState extends State<ThemeHeader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Visibility(
              visible: BlocProvider.of<ThemeBloc>(context).state.themeData ==
                  ThemeState.darkTheme.themeData,
              replacement: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    BlocProvider.of<ThemeBloc>(context)
                        .add(ThemeEventChange(ThemeEventType.toggleDark));
                  },
                  child: Icon(
                    Icons.nights_stay_outlined,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  )),
              child: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    BlocProvider.of<ThemeBloc>(context)
                        .add(ThemeEventChange(ThemeEventType.toggleLight));
                  },
                  child: Icon(
                    Icons.light_mode_outlined,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ))),
        );
      },
    );
  }
}
