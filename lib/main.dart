import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:window_size/window_size.dart';

import './widgets/MyHomePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('RTOP');
    setWindowMaxSize(Size.infinite);
    setWindowMinSize(const Size(750, 550));
    
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: yaruDarkTheme,
      home: MyHomePage(title: 'Rtop'),
    );
  }
}
