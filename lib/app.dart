import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/ai_notes/ai_notes.dart';

class AiNotesApp extends StatelessWidget {
  final SharedPreferences prefs;
  final bool useMock;
  final String? apiKey;

  const AiNotesApp({
    super.key,
    required this.prefs,
    required this.useMock,
    this.apiKey,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RepositoryProvider(
        create: (_) => SummaryRepository(
          dio: Dio(),
          prefs: prefs,
          useMock: useMock,
          apiKey: apiKey,
        ),
        child: MultiBlocProvider(
          providers: [
            // Список грузим сразу при старте.
            BlocProvider(
              create: (ctx) =>
                  SummariesListCubit(ctx.read<SummaryRepository>())..load(),
            ),
            // AiNotesCubit зависит от обоих — repository и list cubit.
            BlocProvider(
              create: (ctx) => AiNotesCubit(
                repository: ctx.read<SummaryRepository>(),
              ),
            ),
          ],
          child: const AiNotesPage(),
        ),
      ),
    );
  }
}
