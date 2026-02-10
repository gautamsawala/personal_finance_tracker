import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/settings/settings_cubit.dart';
import 'bloc/settings/settings_state.dart';
import 'bloc/transaction/transaction_cubit.dart';
import 'data/repo/settings_repo.dart';
import 'data/repo/transaction_repo.dart';
import 'ui/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final transactionRepo = TransactionRepo();
  final settingsRepo = SettingsRepo(prefs);

  runApp(MyApp(
    transactionRepo: transactionRepo,
    settingsRepo: settingsRepo,
  ));
}

class MyApp extends StatelessWidget {
  final TransactionRepo transactionRepo;
  final SettingsRepo settingsRepo;

  const MyApp({
    super.key,
    required this.transactionRepo,
    required this.settingsRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: settingsRepo),
        RepositoryProvider.value(value: transactionRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SettingsCubit(context.read<SettingsRepo>())),
          BlocProvider(
            create: (context) => TransactionCubit(
              transactionRepo: context.read<TransactionRepo>(),
            )..fetchAllTransactions(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(useMaterial3: true, textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme)),
              darkTheme: ThemeData(useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark,
                  ),
                  textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme)),
              home: const HomePage(),
            );
          },
        ),
      ),
    );
  }
}