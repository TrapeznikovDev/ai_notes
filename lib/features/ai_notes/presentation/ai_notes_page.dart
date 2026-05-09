import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/summary.dart';
import 'ai_notes_cubit.dart';
import 'ai_notes_state.dart';
import 'summaries_list_cubit.dart';
import 'widgets/input_section.dart';
import 'widgets/summary_card.dart';

class AiNotesPage extends StatelessWidget {
  const AiNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiNotesCubit, AiNotesState>(
      listener: (context, state) {
        if (state is AiNotesSuccess) {
          context.read<SummariesListCubit>().add(state.summary);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('AI Notes'),
        actions: [
          BlocBuilder<SummariesListCubit, List<Summary>>(
            builder: (context, list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear history',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmClear(context),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InputSection(),
              const SizedBox(height: 16),
              const _StateFeedback(),
              const SizedBox(height: 16),
              Text(
                'Recent summaries',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Expanded(child: _SummariesList()),
            ],
          ),
        ),
      ),
    ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved summaries will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SummariesListCubit>().clear();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _StateFeedback extends StatelessWidget {
  const _StateFeedback();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiNotesCubit, AiNotesState>(
      builder: (context, state) {
        return switch (state) {
          AiNotesIdle() => const SizedBox.shrink(),
          AiNotesLoading() => const _Banner(
              icon: Icons.hourglass_empty,
              text: 'Processing your text...',
              color: Colors.blue,
            ),
          AiNotesSuccess() => const _Banner(
              icon: Icons.check_circle_outline,
              text: 'Summary created. See it below.',
              color: Colors.green,
            ),
          AiNotesError(:final message) => _Banner(
              icon: Icons.error_outline,
              text: message,
              color: Colors.red,
            ),
        };
      },
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Banner({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _SummariesList extends StatelessWidget {
  const _SummariesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummariesListCubit, List<Summary>>(
      builder: (context, list) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No summaries yet.\nGenerate your first one above.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          );
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => SummaryCard(summary: list[i]),
        );
      },
    );
  }
}
