import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_cubit.dart';
import 'bloc/contacts/contacts_cubit.dart';
import 'bloc/transaction_detail/transaction_detail_cubit.dart';
import 'bloc/transactions/transactions_cubit.dart';
import 'core/bloc_utils/app_bloc_observer.dart';
import 'core/route_util/route_generator.dart';
import 'core/route_util/route_names.dart';
import 'repositories/auth_repo.dart';
import 'repositories/contacts_repo.dart';
import 'repositories/transactions_repo.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepo>(create: (context) => AuthRepo()),
        RepositoryProvider<ContactsRepo>(create: (context) => ContactsRepo()),
        RepositoryProvider<TransactionsRepo>(
          create: (context) => TransactionsRepo(),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (BuildContext context) => AuthCubit(context.read()),
          ),
          BlocProvider<ContactsCubit>(
            create: (BuildContext context) => ContactsCubit(context.read()),
          ),
          BlocProvider<TransactionsCubit>(
            create: (BuildContext context) => TransactionsCubit(context.read()),
          ),
          BlocProvider<TransactionDetailCubit>(
            create: (BuildContext context) =>
                TransactionDetailCubit(context.read()),
          ),
        ],
        child: MaterialApp(
          title: 'အချေးအငှား',
          navigatorKey: navigatorKey,
          themeMode: ThemeMode.dark,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          onGenerateRoute: RouteGenerator.onGenerateRoute,
          initialRoute: RouteNames.splashScreen,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: TextTheme(
      titleLarge: TextStyle(color: colorScheme.primary),
      // ...
    ),
    // ...
    fontFamily: "Pyidaungsu",
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(size: 15),
      titleTextStyle: TextStyle(fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black87,
      contentTextStyle: TextStyle(color: Colors.green),
    ),
  );
}

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: TextTheme(
      titleLarge: TextStyle(color: colorScheme.primary),
      // ...
    ),
    fontFamily: "Pyidaungsu",
    appBarTheme: AppBarTheme(iconTheme: IconThemeData(size: 15)),
  );
}
