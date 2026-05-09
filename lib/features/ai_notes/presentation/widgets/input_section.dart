import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ai_notes_cubit.dart';
import '../ai_notes_state.dart';

class InputSection extends StatefulWidget {
  const InputSection({super.key});

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onGenerate() {
    context.read<AiNotesCubit>().generate(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          maxLines: 5,
          maxLength: 5000,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Paste any text to summarize...',
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AiNotesCubit, AiNotesState>(
          buildWhen: (prev, curr) =>
              (prev is AiNotesLoading) != (curr is AiNotesLoading),
          builder: (context, state) {
            final isLoading = state is AiNotesLoading;
            return ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, value, __) {
                final hasText = value.text.trim().isNotEmpty;
                return FilledButton.icon(
                  onPressed: (isLoading || !hasText) ? null : _onGenerate,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(isLoading ? 'Generating...' : 'Generate Summary'),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
