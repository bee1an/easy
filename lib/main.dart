import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:easy/provider/poop_provider.dart';
import 'package:easy/provider/timer_provider.dart';
import 'package:easy/core/theme/app_theme.dart';
import 'package:easy/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PoopProvider()),
        ChangeNotifierProvider(
          create: (context) => TimerProvider(context.read<PoopProvider>()),
        ),
      ],
      child: MaterialApp(
        title: 'Easy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        initialRoute: AppRouter.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
