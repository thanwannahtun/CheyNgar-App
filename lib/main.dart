import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/accounting/accounting_cubit.dart';
import 'bloc/auth/auth_cubit.dart';
import 'bloc/contacts/contacts_cubit.dart';
import 'bloc/theme_mode/theme_mode_cubit.dart';
import 'bloc/transaction_detail/transaction_detail_cubit.dart';
import 'bloc/transactions/transactions_cubit.dart';
import 'bloc/update/app_update_cubit.dart';
import 'bloc/user_profile/user_profile_cubit.dart';
import 'core/app_theme_data.dart';
import 'core/bloc_utils/app_bloc_observer.dart';
import 'core/route_util/route_generator.dart';
import 'core/route_util/route_names.dart';
import 'core/secure_storage_service.dart';
import 'core/update/app_update.dart';
import 'repositories/accounting_repo.dart';
import 'repositories/auth_repo.dart';
import 'repositories/contacts_repo.dart';
import 'repositories/transactions_repo.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the app's existing SecureStorageService for persisting update check timestamps.
    final storage = SecureStorageService.instance;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepo>(create: (context) => AuthRepo()),
        RepositoryProvider<ContactsRepo>(create: (context) => ContactsRepo()),
        RepositoryProvider<TransactionsRepo>(
          create: (context) => TransactionsRepo(),
        ),
        RepositoryProvider<AccountingRepo>(
          create: (context) => AccountingRepo(),
        ),

        // ── App Update Service ────────────────────────────────────────────────
        // Decoupled via AppUpdateServiceInterface. Config values drive all
        // GitHub endpoints — no hardcoded URLs anywhere in the UI layer.
        RepositoryProvider<AppUpdateServiceInterface>(
          create: (_) => GithubAppUpdateService(
            config: UpdateConfig(
              githubOwner: 'thanwannahtun',
              githubRepo: 'CheyNgar-App',
              destinationFilename: 'CheyNgar-latest.apk',
            ),
            storage: RepositoryUpdateStorage(
              reader: (key) => storage.read(key),
              writer: (key, val) => storage.write(key, val),
            ),
          ),
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
          BlocProvider<AccountingCubit>(
            create: (BuildContext context) => AccountingCubit(context.read()),
          ),
          BlocProvider<UserProfileCubit>(
            create: (BuildContext context) => UserProfileCubit(context.read()),
          ),
          BlocProvider<ThemeModeCubit>(
            create: (BuildContext context) =>
                ThemeModeCubit(ThemeMode.system)..init(),
          ),

          // ── App Update Cubit ────────────────────────────────────────────────
          // Calls init() immediately: reads dynamic package version + runs
          // a silent weekly background check if 7 days have elapsed.
          BlocProvider<AppUpdateCubit>(
            create: (ctx) => AppUpdateCubit(
              updateService: ctx.read<AppUpdateServiceInterface>(),
            )..init(),
          ),
        ],
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (BuildContext context, ThemeMode state) => MaterialApp(
            title: 'အချေးအငှား',
            navigatorKey: navigatorKey,
            themeMode: state,
            theme: AppThemeData.buildLightTheme(),
            darkTheme: AppThemeData.buildDarkTheme(),
            onGenerateRoute: RouteGenerator.onGenerateRoute,
            initialRoute: RouteNames.splashScreen,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
