
import 'package:bytebank/screens/counter.dart';
import 'package:bytebank/screens/name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'components/theme.dart';
import 'screens/dashboard.dart';
import 'screens/dashboard.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(BytebankApp());
}

class LogObserver extends BlocObserver{

  @override
  void onChange(Cubit cubit, Change change) {
    debugPrint("${cubit.runtimeType} > $change");
    super.onChange(cubit, change);
  }

}

class BytebankApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Bloc.observer = LogObserver();
    return MaterialApp(
        theme: bytebanckTheme,
      home: DashboardContainer(),
    );
  }
}
