import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:instagram_clone/state/auth/models/auth_results.dart';
import 'package:instagram_clone/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone/state/providers/is_loading_provider.dart';
import 'package:instagram_clone/views/components/loading/loading_screen.dart';
import 'package:instagram_clone/views/login/login_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark(),
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: Consumer(
          builder: (context, ref, child) {
            // displays loading screen
            ref.listen<bool>(
              isLoadingProvider,
              (_, isLoading) {
                if (isLoading) {
                  LoadingScreen.instance().show(
                    context: context,
                  );
                } else {
                  LoadingScreen.instance().hide();
                }
              },
            );

            final isLoggedIn =
                ref.watch(authStateProvider).result == AuthResult.success;

            if (isLoggedIn) {
              return const MainView();
            } else {
              return const LoginView();
            }
          },
        ));
  }
}

// Already logged in
class MainView extends StatefulWidget {
  const MainView({
    super.key,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

// When you're not logged in
class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Main View"),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            return TextButton(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logOut();
              },
              child: const Text(
                'Logout',
              ),
            );
          },
        ));
  }
}
